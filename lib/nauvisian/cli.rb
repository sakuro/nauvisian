# frozen_string_literal: true

require "nauvisian"

require_relative "cli/commands/mod/info"
require_relative "cli/commands/mod/installed"
require_relative "cli/commands/mod/latest"
require_relative "cli/commands/mod/versions"
require_relative "cli/commands/save/mod/list"

require_relative "cli/lister"

require "dry/cli"

module Nauvisian
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "mod info", Nauvisian::CLI::Commands::Mod::Info
      register "mod installed", Nauvisian::CLI::Commands::Mod::Installed
      register "mod latest", Nauvisian::CLI::Commands::Mod::Latest
      register "mod versions", Nauvisian::CLI::Commands::Mod::Versions

      register "save mod list", Nauvisian::CLI::Commands::Save::Mod::List
    end
  end
end
