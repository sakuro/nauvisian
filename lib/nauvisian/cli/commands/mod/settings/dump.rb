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

            def call(**)
              puts Nauvisian::ModSettings.load.to_json
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
