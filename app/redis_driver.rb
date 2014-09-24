require "redis"
require "psych"
require "json"

class RedisDriver
  include Enumerable

  class << self
    def from_env(key)
      new(uri, key)
    end

    private

    def uri
      if config.has_key?("password")
        "redis://:#{config["password"]}@#{config["hostname"]}:#{config["port"]}/0"
      else
        "redis://#{config["hostname"]}:#{config["port"]}/0"
      end
    end

    def config
      JSON.parse(ENV.fetch("VCAP_SERVICES", default_vcap_services)).
        fetch("rediscloud")[0].fetch("credentials")
    end

    def default_vcap_services
      JSON.generate(
        "rediscloud" => [
          { "credentials" => { "hostname" => "localhost",
                               "port" => "6379" } }
        ]
      )
    end
  end

  def initialize(uri, key)
    @redis = Redis.new(url: uri)
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
