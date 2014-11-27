require "minitest/autorun"
require "rack/test"
require_relative "../server"

class HandlersTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  def test_404s_for_nonexistent_match
    delete "/all"
    get "/matches/nonexistent"
    assert_equal 404, last_response.status
  end
end
