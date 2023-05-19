# frozen_string_literal: true

require "tmpdir"

RSpec.describe Nauvisian::Cache::FileSystem do
  around do |example|
    Dir.mktmpdir do |tmpdir|
      @tmpdir = Pathname(tmpdir)
      example.run
    end
  end

  attr_reader :tmpdir

  let(:cache) { Fabricate(:cache_file_system, name: "cache") }

  before do
    allow(Nauvisian::Cache::FileSystem).to receive(:cache_root).and_return(tmpdir)
  end

  describe ".new" do
    context "when ttl is too small" do
      it "raises error" do
        expect { Nauvisian::Cache::FileSystem.new(name: "cache", ttl: 299) }.to raise_error(ArgumentError)
      end
    end

    context "when ttl is the minium" do
      it "does not raise error" do
        expect { Nauvisian::Cache::FileSystem.new(name: "cache", ttl: 300) }.not_to raise_error
      end
    end
  end

  describe "#stale?" do
    subject { cache.__send__(:stale?, path, time) }

    let(:cache) { Fabricate(:cache_file_system, ttl:) }
    let(:path) { instance_double(Pathname) }
    let(:time) { Time.gm(2023, 5, 14, 16, 0, 0) }
    let(:ttl) { 300 }

    before do
      allow(path).to receive(:mtime).and_return(mtime)
    end

    context "when mtime is newer than the current time" do
      let(:mtime) { time + 1 }

      it { is_expected.to be_falsy }
    end

    context "when mtime is equal to the current time" do
      let(:mtime) { time }

      it { is_expected.to be_falsy }
    end

    context "when mtime is TTL older than the current time by TTL exactly" do
      let(:mtime) { time - ttl }

      it { is_expected.to be_falsy }
    end

    context "when mtime is TTL older than the current time by more than TTL" do
      let(:mtime) { time - ttl - 1 }

      it { is_expected.to be_truthy }
    end
  end

  describe "#fetch" do
    subject(:fetch_from_cache) { cache.fetch(key) { "block value" } } # rubocop:disable Style/RedundantFetchBlock

    let(:key) { "key" }
    let(:path) { instance_double(Pathname) }

    before do
      allow(cache).to receive(:generate_path).with(key).and_return(path)
      allow(cache).to receive(:store).with(path, "block value")
    end

    context "when cached data does not exist" do
      before do
        allow(path).to receive(:exist?).and_return(false)
      end

      it "uses the result from the evaluation" do
        expect(fetch_from_cache).to eq("block value")
      end
    end

    context "when cached data exists" do
      before do
        allow(path).to receive(:exist?).and_return(true)
        allow(path).to receive(:binread).and_return("cached value")
      end

      context "when cached data is stale" do
        before do
          allow(cache).to receive(:stale?).with(path, instance_of(Time)).and_return(true)
          allow(cache).to receive(:store).with(path, "block value")
        end

        it "does not use the cached data" do
          fetch_from_cache
          expect(path).not_to have_received(:binread)
        end

        it "uses the result from the evaluation" do
          expect(fetch_from_cache).to eq("block value")
        end
      end

      context "when cached data is fresh" do
        before do
          allow(cache).to receive(:stale?).with(path, instance_of(Time)).and_return(false)
        end

        it "uses the cached data" do
          expect(fetch_from_cache).to eq("cached value")
          expect(path).to have_received(:binread)
        end

        it "does not call the block" do
          expect {|block| cache.fetch(key, &block) }.not_to yield_control
        end
      end
    end
  end
end
