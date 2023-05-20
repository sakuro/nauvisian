# frozen_string_literal: true

require_relative "../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Enable < Dry::CLI::Command
          include MessageHelper

          desc "Enable a installed MOD"
          argument :mod, desc: "Target MOD", required: true

          option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s

          def call(mod:, **options)
            mod_directory = Pathname(options[:mod_directory])
            mod_list_path = mod_directory / "mod-list.json"
            list = Nauvisian::ModList.load(mod_list_path)
            mod = Nauvisian::Mod[name: mod]
            list.enable(mod)
            list.save(mod_list_path)
          rescue Nauvisian::ModNotFound
            message "❌ You can't enable a MOD which is not in the MOD list (#{mod.name})"
            exit 1
          end
        end
      end
    end
  end
end
