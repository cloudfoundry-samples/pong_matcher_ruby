require "redis"
require "psych"

class RedisDriver
  include Enumerable

  def initialize(key)
    @redis = Redis.new
    @key = key
  end

  def <<(value)
    redis.rpush(key, Psych.dump(value))
  end

  def clear
    redis.del(key)
  end

  def each(&block)
    elements.each do |element|
      block.call(Psych.load(element))
    end
  end

  def length
    redis.llen(key)
  end

  private

  def elements
    redis.lrange(key, 0, length - 1)
  end

  attr_reader :redis, :key
end
