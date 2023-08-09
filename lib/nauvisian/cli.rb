# frozen_string_literal: true

require "pathname"

require "dry/cli"

require "nauvisian"

require_relative "cli/commands/mod/disable"
require_relative "cli/commands/mod/download"
require_relative "cli/commands/mod/enable"
require_relative "cli/commands/mod/info"
require_relative "cli/commands/mod/installed"
require_relative "cli/commands/mod/latest"
require_relative "cli/commands/mod/settings/dump"
require_relative "cli/commands/mod/settings/load"
require_relative "cli/commands/mod/versions"
require_relative "cli/commands/save/mod/list"
require_relative "cli/commands/save/mod/sync"

module Nauvisian
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "mod disable", Nauvisian::CLI::Commands::Mod::Disable
      register "mod enable", Nauvisian::CLI::Commands::Mod::Enable
      register "mod download", Nauvisian::CLI::Commands::Mod::Download
      register "mod info", Nauvisian::CLI::Commands::Mod::Info
      register "mod installed", Nauvisian::CLI::Commands::Mod::Installed
      register "mod latest", Nauvisian::CLI::Commands::Mod::Latest
      register "mod versions", Nauvisian::CLI::Commands::Mod::Versions
      register "mod settings dump", Nauvisian::CLI::Commands::Mod::Settings::Dump
      register "mod settings load", Nauvisian::CLI::Commands::Mod::Settings::Load

      register "save mod list", Nauvisian::CLI::Commands::Save::Mod::List
      register "save mod sync", Nauvisian::CLI::Commands::Save::Mod::Sync

      DEFAULT_NVSNRC = File.join(__dir__, "../../nvsnrc.default")
      private_constant :DEFAULT_NVSNRC

      config_path = File.join(ENV.fetch("XDG_CONFIG_HOME", File.expand_path("~/.config")), "nvsnrc")
      FileUtils.cp(DEFAULT_NVSNRC, config_path) unless File.exist?(config_path)
      load(config_path)
    end
  end
end
