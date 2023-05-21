# frozen_string_literal: true

require "redis"
require "redis-namespace"

require "digest/md5"
require "pathname"
require "securerandom"

module Nauvisian
  module Cache
    class Redis
      MINIMUM_TTL = 5 * 60
      private_constant :MINIMUM_TTL

      MINIMUM_LOCK_TTL = 5
      private_constant :MINIMUM_LOCK_TTL

      def self.redis
        @redis ||= ::Redis.new(url: ENV.fetch("REDIS_URL"))
      end

      def initialize(name:, ttl: MINIMUM_TTL, lock_ttl: MINIMUM_LOCK_TTL)
        raise ArgumentError, "ttl is too small (must be >= #{MINIMUM_TTL})" if ttl < MINIMUM_TTL
        raise ArgumentError, "lock_ttl is too small (must be >= #{MINIMUM_LOCK_TTL})" if lock_ttl < MINIMUM_LOCK_TTL

        @ttl = ttl
        @lock_ttl = lock_ttl
        @cache = ::Redis::Namespace.new(name, redis: self.class.redis)
      end

      def fetch(key)
        cached_value = @cache.get(key)
        return cached_value if cached_value

        lock_key = "lock:#{key}"
        lock_value = SecureRandom.uuid
        locked = @cache.set(lock_key, lock_value, nx: true, ex: @lock_ttl)
        return fetch(key) { yield } unless locked

        begin
          yield.tap {|value| @cache.set(key, value, ex: @ttl) }
        ensure
          @cache.del(lock_key) if @cache.get(lock_key) == lock_value # locked by me
        end
      end
    end
  end
end
