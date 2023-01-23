# frozen_string_literal: true

require "nauvisian"

require "dry/cli"

require "csv"

module Nauvisian
  module CLI
    module Commands
      module Save
        module Mod
          class List < Dry::CLI::Command
            desc "List MODs used in the given save"
            argument :file, desc: "Save file of a Factorio game", required: true
            option :format, default: "plain", values: %w[csv gfm plain], desc: "Output format"

            def call(file:, **options)
              file_path = Pathname(file)
              save = Nauvisian::Save.load(file_path)
              formatter = FORMATTERS.fetch(options[:format].to_sym).new
              # Bring the "base" MOD first. Others are sorted case-insenstively
              base, rest = save.mods.partition {|mod, _version| mod.base? }
              formatter.output(base + rest.sort_by {|mod, _version| mod.name.downcase })
            end

            module Formatter
              class Csv
                def output(mods)
                  CSV(headers: %w[Name Version], write_headers: true) do |out|
                    mods.each do |mod, version|
                      out << [mod.name, version]
                    end
                  end
                end
              end

              class Gfm
                def output(mods)
                  puts "| Name | Version |"
                  puts "|:-|-:|"
                  mods.each do |mod, version|
                    puts "| %s | %s |" % [mod.name, version]
                  end
                end
              end

              class Plain
                def output(mods)
                  mods.each do |mod, version|
                    puts "%s %s" % [mod.name, version]
                  end
                end
              end
            end

            FORMATTERS = {
              plain: Formatter::Plain,
              gfm: Formatter::Gfm,
              csv: Formatter::Csv
            }.freeze
            private_constant :FORMATTERS
          end
        end
      end
    end
  end
end
