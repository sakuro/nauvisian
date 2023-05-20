# frozen_string_literal: true

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Disable < Dry::CLI::Command
          desc "Disable a installed MOD"
          argument :mod, desc: "Target MOD", required: true

          option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s

          def call(mod:, **options)
            mod_directory = Pathname(options[:mod_directory])
            mod_list_path = mod_directory / "mod-list.json"
            list = Nauvisian::ModList.load(mod_list_path)
            mod = Nauvisian::Mod[name: mod]
            list.disable(mod)
            list.save(mod_list_path)
          rescue Nauvisian::ModNotFound
            puts "You can't disable a MOD which is not in the MOD list"
            exit 1
          end
        end
      end
    end
  end
end
