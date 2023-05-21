# frozen_string_literal: true

require "mock_redis"

RSpec.describe Nauvisian::Cache::Redis do
  let(:cache) { Fabricate(:cache_redis, name: "cache") }

  before do
    mock_redis = MockRedis.new
    Nauvisian::Cache::Redis.instance_variable_set(:@redis, mock_redis)
  end

  # define accessor methods for convenience
  Nauvisian::Cache::Redis.prepend(Module.new {
    attr_reader :cache
  })

  describe ".new" do
    context "when ttl is too small" do
      it "raises error" do
        expect { Nauvisian::Cache::Redis.new(name: "cache", ttl: 299) }.to raise_error(ArgumentError)
      end
    end

    context "when ttl is the minium" do
      it "does not raise error" do
        expect { Nauvisian::Cache::Redis.new(name: "cache", ttl: 300) }.not_to raise_error
      end
    end

    context "when lock_ttl is too small" do
      it "raises error" do
        expect { Nauvisian::Cache::Redis.new(name: "cache", lock_ttl: 4) }.to raise_error(ArgumentError)
      end
    end

    context "when lock_ttl is the minium" do
      it "does not raise error" do
        expect { Nauvisian::Cache::Redis.new(name: "cache", lock_ttl: 5) }.not_to raise_error
      end
    end
  end

  describe "#fetch" do
    subject(:fetch_from_cache) { cache.fetch(key) { "block value" } } # rubocop:disable Style/RedundantFetchBlock

    let(:key) { "key" }

    context "when cached data does not exist" do
      before do
        cache.cache.del(key)
      end

      it "uses the result from the evaluation" do
        expect(fetch_from_cache).to eq("block value")
      end
    end

    context "when cached data exists" do
      before do
        cache.cache.set(key, "cached value")
      end

      it "uses the cached data" do
        expect(fetch_from_cache).to eq("cached value")
      end

      it "does not call the block" do
        expect {|block| cache.fetch(key, &block) }.not_to yield_control
      end
    end
  end
end
