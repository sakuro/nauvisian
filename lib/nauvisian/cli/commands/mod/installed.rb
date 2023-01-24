# frozen_string_literal: true

require_relative "../../lister"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Installed < Dry::CLI::Command
          desc "List installed MODs"
          option :format, default: "plain", values: Nauvisian::CLI::Lister.all, desc: "Output format"

          def call(*, **options)
            mods = Nauvisian::ModList.load.sort
            rows = mods.map {|mod, version| {"Name" => mod.name, "Enabled" => version} }

            lister = Nauvisian::CLI::Lister.for(options[:format].to_sym).new(%w(Name Enabled))
            lister.list(rows)
          end
        end
      end
    end
  end
end
