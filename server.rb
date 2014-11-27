require "sinatra"
require "json"
require_relative "redis_driver"

db = {
  match_requests: RedisDriver.from_env("match_requests"),
  matches: RedisDriver.from_env("matches"),
  results: RedisDriver.from_env("results"),
}

delete "/all" do
  db[:match_requests].clear
  db[:matches].clear
  db[:results].clear
  [200, {}, []]
end

put "/match_requests/:id" do |id|
  payload = JSON.parse(request.body.read)
  player_id = payload.fetch("player")

  new_match_request = { id: id, requester_id: player_id }
  db[:match_requests] << new_match_request

  open_match_request = first_open_match_request(db, player_id)
  if open_match_request
    record_match(db, open_match_request, new_match_request)
  end

  [200, {}, []]
end

get "/match_requests/:id" do |match_request_id|
  match_request = db[:match_requests].detect { |match_request|
    match_request[:id] == match_request_id
  }

  if match_request
    found_match = find_unplayed_match(db, match_request) || {}
    [
      200,
      { "Content-Type" => "application/json" },
      [ { id: match_request[:id],
          player: match_request[:requester_id],
          match_id: found_match[:id] }.to_json ]
    ]
  else
    [
      404,
      { "Content-Type" => "application/json" },
      []
    ]
  end
end

get "/matches/:id" do |match_id|
  match = db[:matches].detect { |match| match[:id] == match_id }

  if match
    [
      200,
      { "Content-Type" => "application/json" },
      [ match.to_json ]
    ]
  else
    [
      404,
      { "Content-Type" => "application/json" },
      []
    ]
  end
end

post "/results" do
  result = JSON.parse(request.body.read)
  db[:results] << { match_id: result["match_id"],
                    winner: result["winner"],
                    loser: result["loser"] }
  [
    201,
    { "Location" => "/some/place" },
    []
  ]
end

def record_match(db, open_match_request, new_match_request)
  db[:matches] << { id: SecureRandom.uuid,
                    match_request_1_id: open_match_request[:id],
                    match_request_2_id: new_match_request[:id],
                    player_1: open_match_request[:requester_id],
                    player_2: new_match_request[:requester_id] }
end

def find_unplayed_match(db, match_request)
  db[:matches].
    reject { |match| played_match_ids(db).include?(match[:id]) }.
    detect { |match| match.values_at(:player_1, :player_2).include?(match_request[:requester_id]) }
end

def played_match_ids(db)
  db[:results].map { |result| result[:match_id] }
end

def first_open_match_request(db, player_id)
  unfulfilled_match_requests(db).detect { |match_request|
    inappropriate_opponents = [player_id] + previous_opponents(db, player_id)
    !inappropriate_opponents.include?(match_request[:requester_id])
  }
end

def unfulfilled_match_requests(db)
  db[:match_requests].select { |match_request|
    db[:matches].none? { |match|
      match.values_at(:match_request_1_id, :match_request_2_id).include?(match_request[:id])
    }
  }
end

def previous_opponents(db, player_id)
  results_involving_player(db, player_id).map { |result|
    result[:winner] == player_id ? result[:loser] : result[:winner]
  }
end

def results_involving_player(db, player_id)
  db[:results].select { |result|
    [result[:winner], result[:loser]].include?(player_id)
  }
end
