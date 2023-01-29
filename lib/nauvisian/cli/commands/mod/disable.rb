# frozen_string_literal: true

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Disable < Dry::CLI::Command
          desc "Disable a installed MOD"
          argument :mod, desc: "Target MOD", required: true

          option :mods_dir, desc: "Directory MODs are installed", required: false, default: Nauvisian.platform.mods_directory.to_s

          def call(mod:, **options)
            mod_list_path = Pathname(options[:mods_dir]) + "mod-list.json"
            list = Nauvisian::ModList.load(mod_list_path)
            mod = Nauvisian::Mod[name: mod]
            list.disable(mod)
            list.save
          rescue Nauvisian::ModList::NotListedError
            puts "You can't disable a MOD which is not in the MOD list"
            exit 1
          end
        end
      end
    end
  end
end