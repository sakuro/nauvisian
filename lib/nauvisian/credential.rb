# frozen_string_literal: true

require "json"

require "rack/utils"

module Nauvisian
  Credential = Data.define(:username, :token) # rubocop:disable Style/ConstantVisibility

  class Credential
    class << self
      private :new
    end

    def self.from_env
      self[username: ENV.fetch("FACTORIO_SERVICE_USERNAME"), token: ENV.fetch("FACTORIO_SERVICE_TOKEN")]
    end

    def self.from_player_data_file(player_data_file_path:)
      data = JSON.load_file(player_data_file_path)
      self[username: data["service-username"], token: data["service-token"]]
    end
  end
end
