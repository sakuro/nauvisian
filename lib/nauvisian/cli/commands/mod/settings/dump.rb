# frozen_string_literal: true

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
            rescue => e
              puts e.message
              exit 1
            end
          end
        end
      end
    end
  end
end
