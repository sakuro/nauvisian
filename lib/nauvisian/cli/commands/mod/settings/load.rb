# frozen_string_literal: true

require_relative "../../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        module Settings
          class Load < Dry::CLI::Command
            include MessageHelper

            desc "Load MOD settings"
            argument :settings_json_path, desc: "Path of settings dumped as JSON", required: true
            option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s

            def call(settings_json_path:, **options)
              mod_directory = Pathname(options[:mod_directory])
              dumped_settings = JSON.parse(File.read(settings_json_path))
              version = Nauvisian::Version64[*dumped_settings["version"]]
              properties = dumped_settings.except("version")
              settings = Nauvisian::ModSettings.new(version:, properties:)

              mod_settings_path = mod_directory / "mod-settings.dat"
              settings.save(mod_settings_path)
            rescue => e
              message(e)
              exit 1
            end
          end
        end
      end
    end
  end
end
