# frozen_string_literal: true

require_relative "../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Latest < Dry::CLI::Command
          include MessageHelper

          desc "Show the latest version of MOD"
          argument :mod, desc: "Target MOD", required: true

          def call(mod:, **)
            api = Nauvisian::API.new
            mod = Nauvisian::Mod[name: mod]
            releases = api.releases(mod)
            latest = releases.max_by(&:released_at)

            puts latest.version
          rescue => e
            message(e)
            exit 1
          end
        end
      end
    end
  end
end
