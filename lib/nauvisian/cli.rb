# frozen_string_literal: true

require "dry/cli"

require "nauvisian"

require_relative "cli/commands/mod/disable"
require_relative "cli/commands/mod/enable"
require_relative "cli/commands/mod/info"
require_relative "cli/commands/mod/installed"
require_relative "cli/commands/mod/latest"
require_relative "cli/commands/mod/settings/dump"
require_relative "cli/commands/mod/versions"
require_relative "cli/commands/save/mod/list"

module Nauvisian
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "mod disable", Nauvisian::CLI::Commands::Mod::Disable
      register "mod enable", Nauvisian::CLI::Commands::Mod::Enable
      register "mod info", Nauvisian::CLI::Commands::Mod::Info
      register "mod installed", Nauvisian::CLI::Commands::Mod::Installed
      register "mod latest", Nauvisian::CLI::Commands::Mod::Latest
      register "mod versions", Nauvisian::CLI::Commands::Mod::Versions
      register "mod settings dump", Nauvisian::CLI::Commands::Mod::Settings::Dump

      register "save mod list", Nauvisian::CLI::Commands::Save::Mod::List
    end
  end
end
