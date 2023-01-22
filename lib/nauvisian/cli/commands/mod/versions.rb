# frozen_string_literal: true

require "nauvisian"

require "dry/cli"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Versions < Dry::CLI::Command
          desc "List available versions of MOD"
          argument :mod, desc: "Target MOD", required: true

          def call(mod:, **)
            api = Nauvisian::API.new
            mod = Nauvisian::Mod[name: mod]
            releases = api.releases(mod).sort_by(&:released_at)

            releases.each do |release|
              puts release.version
            end
          end
        end
      end
    end
  end
end
