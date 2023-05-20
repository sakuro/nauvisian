# frozen_string_literal: true

require_relative "../../lister"
require_relative "../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Installed < Dry::CLI::Command
          include MessageHelper

          desc "List installed MODs"
          option :format, default: "plain", values: Nauvisian::CLI::Lister.all, desc: "Output format"

          def call(*, **options)
            mods = Nauvisian::ModList.load.sort
            rows = mods.map {|mod, enabled| {"Name" => mod.name, "Enabled" => enabled} }

            lister = Nauvisian::CLI::Lister.for(options[:format].to_sym).new(%w(Name Enabled))
            lister.list(rows)
          rescue => e
            message(e)
            exit 1
          end
        end
      end
    end
  end
end
