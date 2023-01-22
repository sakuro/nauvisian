# frozen_string_literal: true

require "nauvisian"

require "nauvisian/cli/commands/mod/info"
require "nauvisian/cli/commands/mod/latest"
require "nauvisian/cli/commands/mod/versions"
require "nauvisian/cli/commands/save/mod/list"

require "dry/cli"

module Nauvisian
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "mod info", Nauvisian::CLI::Commands::Mod::Info
      register "mod latest", Nauvisian::CLI::Commands::Mod::Latest
      register "mod versions", Nauvisian::CLI::Commands::Mod::Versions

      register "save mod list", Nauvisian::CLI::Commands::Save::Mod::List
    end
  end
end
