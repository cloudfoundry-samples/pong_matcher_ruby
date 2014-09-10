require "sinatra"
require "json"

db = {
  match_requests: {},
  matches: []
}

def base_uri(request)
  "#{request.scheme}://#{request.host}:#{request.port}"
end

def find_match(matches, match_request)
  matches.detect { |match|
    match.values_at(:player_1, :player_2).include?(match_request[:requester_id])
  }
end

delete "/all" do
  db[:match_requests].clear
  db[:matches].clear
end

put "/match_requests/:id" do |id|
  player_id = JSON.parse(request.body.read).fetch("player")

  open_match_request = db[:match_requests].detect { |pair|
    match_request_id, match_request = pair

    match_request[:requester_id] != player_id &&
      find_match(db[:matches], match_request).nil?
  }

  if open_match_request
    player_1 = open_match_request[1][:requester_id]

    puts "Matched #{player_1} with #{player_id}"

    db[:matches] << { id: SecureRandom.uuid,
                      player_1: player_1,
                      player_2: player_id }
  end

  db[:match_requests][id] = { requester_id: player_id }

  [201, { "Location" => "#{base_uri(request)}/match_requests/#{id}"}, []]
end

get "/match_requests/:id" do |match_request_id|
  match_request = db[:match_requests][match_request_id]
  found_match = find_match(db[:matches], match_request)

  if found_match
    [
      200,
      { "Content-Type" => "application/json" },
      [ JSON.generate(match_uri: "#{base_uri(request)}/matches/#{found_match[:id]}") ]
    ]
  else
    [
      404,
      { "Content-Type" => "application/json" },
      [ "{}" ]
    ]
  end
end
