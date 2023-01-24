# frozen_string_literal: true

require "nauvisian"

require "dry/cli"

require "json"

module Nauvisian
  module CLI
    module Commands
      module Mod
        module Settings
          class Dump < Dry::CLI::Command
            desc "Dump MOD settings"

            def call(**)
              puts Nauvisian::ModSettings.load.to_json
            end
          end
        end
      end
    end
  end
end
