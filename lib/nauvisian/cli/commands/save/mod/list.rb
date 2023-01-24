# frozen_string_literal: true

require "nauvisian"
require "nauvisian/cli/lister"

require "dry/cli"

require "csv"

module Nauvisian
  module CLI
    module Commands
      module Save
        module Mod
          class List < Dry::CLI::Command
            desc "List MODs used in the given save"
            argument :file, desc: "Save file of a Factorio game", required: true
            option :format, default: "plain", values: Nauvisian::CLI::Lister.all, desc: "Output format"

            def call(file:, **options)
              file_path = Pathname(file)
              save = Nauvisian::Save.load(file_path)
              lister = Nauvisian::CLI::Lister.for(options[:format].to_sym).new(%w(Name Version))
              # Bring the "base" MOD first. Others are sorted case-insenstively
              base, rest = save.mods.partition {|mod, _version| mod.base? }
              mods = base + rest.sort_by {|mod, _version| mod.name.downcase }
              rows = mods.map {|mod, version| {"Name" => mod.name, "Version" => version} }
              lister.list(rows)
            end
          end
        end
      end
    end
  end
end
