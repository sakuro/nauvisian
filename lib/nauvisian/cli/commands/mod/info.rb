# frozen_string_literal: true

require "nauvisian"

require "dry/cli"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Info < Dry::CLI::Command
          desc "Show info of MOD"
          argument :mod, desc: "Target MOD", required: true

          def call(mod:, **)
            api = Nauvisian::API.new
            mod = Nauvisian::Mod[name: mod]
            detail = api.detail(mod)

            puts <<~DETAIL
              Name: #{detail.name}
              Category: #{detail.category}
              Downloads: #{detail.downloads_count}
              Title: #{detail.title}
              Summary: #{detail.summary}
              Owner: #{detail.owner}
            DETAIL
          end
        end
      end
    end
  end
end
