# frozen_string_literal: true

require "json"

module Nauvisian
  Credential = Data.define(:username, :token)

  class Credential
    class << self
      private :new
    end

    def self.from_env
      self[username: ENV.fetch("FACTORIO_SERVICE_USERNAME"), token: ENV.fetch("FACTORIO_SERVICE_TOKEN")]
    end

    def self.from_player_data_file(player_data_file_path: Nauvisian.platform.user_data_directory + "player-data.json")
      data = JSON.load_file(player_data_file_path)
      self[username: data["service-username"], token: data["service-token"]]
    end
  end
end
