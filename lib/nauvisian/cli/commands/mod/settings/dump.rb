# frozen_string_literal: true

require_relative "../../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        module Settings
          class Dump < Dry::CLI::Command
            include MessageHelper

            desc "Dump MOD settings"
            option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s

            def call(**options)
              mod_directory = Pathname(options[:mod_directory])
              mod_settings_path = mod_directory / "mod-settings.dat"
              settings = Nauvisian::ModSettings.load(mod_settings_path)
              puts settings.to_json
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
