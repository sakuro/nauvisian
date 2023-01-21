# frozen_string_literal: true

require "json"
require "tmpdir"

RSpec.describe Nauvisian::Credential do
  describe ".from_env" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
    end

    context "when FACTORIO_SERVICE_USERNAME is missing" do
      before do
        allow(ENV).to receive(:fetch).with("FACTORIO_SERVICE_USERNAME").and_raise(KeyError)
      end

      it "raises KeyError" do
        expect { Nauvisian::Credential.from_env }.to raise_error(KeyError)
      end
    end

    context "when FACTORIO_SERVICE_TOKEN is missing" do
      before do
        allow(ENV).to receive(:fetch).with("FACTORIO_SERVICE_TOKEN").and_raise(KeyError)
      end

      it "raises KeyError" do
        expect { Nauvisian::Credential.from_env }.to raise_error(KeyError)
      end
    end

    context "when both FACTORIO_SERVICE_USERNAME and FACTORIO_SERVICE_TOKEN are set" do
      before do
        allow(ENV).to receive(:fetch).with("FACTORIO_SERVICE_USERNAME").and_return("my-username")
        allow(ENV).to receive(:fetch).with("FACTORIO_SERVICE_TOKEN").and_return("my-token")
      end

      it "instantiates Credential" do
        expect(Nauvisian::Credential.from_env).to eq(Nauvisian::Credential[username: "my-username", token: "my-token"])
      end
    end
  end

  describe ".from_player_data_file" do
    context "when the player data file does not exist" do
      it "raises Error::ENOENT" do
        expect { Nauvisian::Credential.from_player_data_file(player_data_file_path: "non-exist.json") }.to raise_error(Errno::ENOENT)
      end
    end

    context "when the player data file is unreadable" do
      let!(:unreadable_player_data_file_path) do
        Dir::Tmpname.create(["player-data", ".json"]) do |tmp|
          FileUtils.cp("spec/fixtures/credential/unreadable.json", tmp)
          FileUtils.chmod("a-r", tmp)
        end
      end

      it "raises Error::EACCES" do
        expect { Nauvisian::Credential.from_player_data_file(player_data_file_path: unreadable_player_data_file_path) }.to raise_error(Errno::EACCES)
      end
    end

    context "when the player data file is unparsable as JSON" do
      it "raises JSON::ParserError" do
        expect { Nauvisian::Credential.from_player_data_file(player_data_file_path: "spec/fixtures/credential/broken.json") }.to raise_error(JSON::ParserError)
      end
    end

    context "when the player data file is valid" do
      it "instantiates Credential" do
        expect(Nauvisian::Credential.from_player_data_file(player_data_file_path: "spec/fixtures/credential/valid.json")).to eq(Nauvisian::Credential[username: "my-username", token: "my-token"])
      end
    end
  end
end
