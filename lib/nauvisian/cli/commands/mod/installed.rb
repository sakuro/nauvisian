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
          option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s

          def call(*, **options)
            mod_directory = Pathname(options[:mod_directory])
            mod_list_path = mod_directory / "mod-list.json"
            mods = Nauvisian::ModList.load(mod_list_path).sort
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
