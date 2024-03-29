# frozen_string_literal: true

require_relative "../../../lister"
require_relative "../../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Save
        module Mod
          class List < Dry::CLI::Command
            include MessageHelper

            desc "List MODs used in the given save"
            argument :file, desc: "Save file of a Factorio game", required: true
            option :format, default: "plain", values: Nauvisian::CLI::Lister.all, desc: "Output format"

            def call(file:, **options)
              file_path = Pathname(file)
              save = Nauvisian::Save.load(file_path)
              mods = save.mods.sort
              rows = mods.map {|mod, version| {"Name" => mod.name, "Version" => version} }

              lister = Nauvisian::CLI::Lister.for(options[:format].to_sym).new(%w(Name Version))
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
end
