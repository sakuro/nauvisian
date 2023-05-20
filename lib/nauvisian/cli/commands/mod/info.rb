# frozen_string_literal: true

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
              URL: #{detail.url}
              Title: #{detail.title}
              Summary: #{detail.summary}
              Owner: #{detail.owner}
              Created at: #{detail.created_at}
              Description: #{detail.description}
            DETAIL
          rescue => e
            puts e.message
            exit 1
          end
        end
      end
    end
  end
end
