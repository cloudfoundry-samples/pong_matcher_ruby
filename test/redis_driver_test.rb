require "minitest/autorun"
require_relative "../redis_driver"
require_relative "collection_examples"

class RedisDriverTest < MiniTest::Test
  include CollectionExamples

  def setup
    @coll = RedisDriver.new("test_collection")
    @coll.clear
  end
end
