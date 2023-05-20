# frozen_string_literal: true

require_relative "../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Versions < Dry::CLI::Command
          include MessageHelper

          desc "List available versions of MOD"
          argument :mod, desc: "Target MOD", required: true

          def call(mod:, **)
            api = Nauvisian::API.new
            mod = Nauvisian::Mod[name: mod]
            releases = api.releases(mod).sort_by(&:released_at)

            releases.each do |release|
              puts release.version
            end
          rescue => e
            message(e)
            exit 1
          end
        end
      end
    end
  end
end
