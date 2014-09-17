require "sinatra"
require "json"

db = {
  match_requests: [],
  matches: [],
  results: []
}

delete "/all" do
  db[:match_requests].clear
  db[:matches].clear
  db[:results].clear
end

put "/match_requests/:id" do |id|
  payload = JSON.parse(request.body.read)
  player_id = payload.fetch("player")

  record_match_request(db, id, player_id)

  open_match_request = first_open_match_request(db, player_id)
  if open_match_request
    record_match(db, open_match_request, id, player_id)
  end

  [200, {}, []]
end

def record_match(db, open_match_request, request_id, requester_id)
  db[:matches] << { id: SecureRandom.uuid,
                    match_request_1_id: open_match_request[:id],
                    match_request_2_id: request_id,
                    player_1: open_match_request[:requester_id],
                    player_2: requester_id }
end

def record_match_request(db, request_id, requester_id)
  db[:match_requests] << { id: request_id, requester_id: requester_id }
end

get "/match_requests/:id" do |match_request_id|
  match_request = db[:match_requests].detect { |match_request| match_request[:id] == match_request_id }
  found_match = find_unplayed_match(db, match_request)

  if found_match
    [
      200,
      { "Content-Type" => "application/json" },
      [ { match_id: found_match[:id] }.to_json ]
    ]
  else
    [
      404,
      { "Content-Type" => "application/json" },
      [ db.to_json ]
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

def base_uri(request)
  "#{request.scheme}://#{request.host}:#{request.port}"
end

def find_unplayed_match(db, match_request)
  played_match_ids = db[:results].map { |result| result[:match_id] }
  db[:matches].
    reject { |match| played_match_ids.include?(match[:id]) }.
    detect { |match| match.values_at(:player_1, :player_2).include?(match_request[:requester_id]) }
end

def unfulfilled_match_requests(db)
  db[:match_requests].select { |match_request|
    db[:matches].none? { |match|
      match.values_at(:match_request_1_id, :match_request_2_id).include?(match_request[:id])
    }
  }
end

def first_open_match_request(db, player_id)
  unfulfilled_match_requests(db).detect { |match_request|
    results_involving_player = db[:results].select { |result|
      [result[:winner], result[:loser]].include?(player_id)
    }
    previous_opponents = results_involving_player.map { |result|
      result[:winner] == player_id ? result[:loser] : result[:winner]
    }
    inappropriate_opponents = previous_opponents + [player_id]
    !inappropriate_opponents.include?(match_request[:requester_id])
  }
end
