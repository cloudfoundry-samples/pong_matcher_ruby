require "sinatra"
require "json"

db = {
  match_requests: {},
  matches: [],
  results: []
}

def log(msg)
  puts "***************** #{msg}"
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
  db[:match_requests].select { |match_request_id, match_request|
    db[:matches].none? { |match|
      match.values_at(:match_request_1_id, :match_request_2_id).include?(match_request_id)
    }
  }
end

def first_open_match_request(db, player_id)
  log "Looking for an open match request for #{player_id}"

  unfulfilled_match_requests(db).detect { |match_request_id, match_request|
    log "Does this suit? #{match_request}"

    results_involving_player = db[:results].select { |result|
      [result[:winner], result[:loser]].include?(player_id)
    }
    previous_opponents = results_involving_player.map { |result|
      result[:winner] == player_id ? result[:loser] : result[:winner]
    }
    inappropriate_opponents = previous_opponents + [player_id]

    !inappropriate_opponents.include?(match_request[:requester_id]).tap do |result|
      log(
        result ? "Yes!" : [
          "No!",
          "previous: #{previous_opponents}",
          "inappropriate: #{inappropriate_opponents}",
        ].join("\n")
      )
    end
  }
end

delete "/all" do
  db[:match_requests].clear
  db[:matches].clear
  db[:results].clear
end

put "/match_requests/:id" do |id|
  payload = JSON.parse(request.body.read)
  player_id = payload.fetch("player")

  log "New request from #{player_id}"

  open_match_request_id, open_match_request = first_open_match_request(db, player_id)

  if open_match_request
    log "Open match request: #{open_match_request}"
    player_1 = open_match_request[:requester_id]

    db[:matches] << { id: SecureRandom.uuid,
                      match_request_1_id: open_match_request_id,
                      match_request_2_id: id,
                      player_1: player_1,
                      player_2: player_id }

    log "Matches are now: #{db[:matches]}"
  else
    log "No open match request!"
  end

  db[:match_requests][id] = { requester_id: player_id }

  log "Unfulfilled requests is now: #{unfulfilled_match_requests(db)}"

  [200, {}, []]
end

get "/match_requests/:id" do |match_request_id|
  match_request = db[:match_requests][match_request_id]
  log "Checking on request #{match_request}"
  found_match = find_unplayed_match(db, match_request)

  if found_match
    log "Found match: #{found_match}"
    [
      200,
      { "Content-Type" => "application/json" },
      [ { match_id: found_match[:id] }.to_json ]
    ]
  else
    log "No match found!"
    [
      404,
      { "Content-Type" => "application/json" },
      [ db.to_json ]
    ]
  end
end

post "/results" do
  result = JSON.parse(request.body.read)
  log "Result in: #{result}"
  db[:results] << { match_id: result["match_id"],
                    winner: result["winner"],
                    loser: result["loser"] }
  [
    201,
    { "Location" => "/some/place" },
    []
  ]
end
