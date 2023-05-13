# frozen_string_literal: true

require_relative "../../../download_helper"

module Nauvisian
  module CLI
    module Commands
      module Save
        module Mod
          class Sync < Dry::CLI::Command
            include DownloadHelper

            desc "Synchronize MODs and settings with the given save"
            argument :save_file, desc: "Save file of a Factorio game", required: true
            option :exact, desc: "Use exact version", type: :boolean, default: false

            def call(save_file:, **options)
              save_file_path = Pathname(save_file)
              save = Nauvisian::Save.load(save_file_path)
              mods_in_save = save.mods.sort # [[mod, version]]

              # [[mod, [version...]] # can have multiple versions of a MOD
              zips = Nauvisian.platform.mods_directory.glob("*.zip")
              directories = Nauvisian.platform.mods_directory.entries.select(&:directory?)
              existing_mods = [*zips, *directories].filter_map {|path|
                /(?<name>.*)_(?<version>\d+\.\d+\.\d+)(?:\.zip|$)\z/ =~ path.basename.to_s && [Nauvisian::Mod[name:], Nauvisian::Version24[version]]
              }.group_by(&:first).transform_values {|v| v.map(&:last) }.to_a

              credential = find_credential
              downloader = Nauvisian::Downloader.new(credential:, progress: Nauvisian::Progress::Bar)

              mods_in_save.each do |mod, version|
                next if mod.base?

                puts "Checking #{mod.name} #{version}"
                case existing_mods
                in [*, [^mod, [*, ^version, *]], *]
                  # exact version ixists, nothing to do
                  puts "✓ Exact version exists, nothing to do"
                in [*, [^mod, [*versions]], *]
                  if options[:exact]
                    puts "↓ some versions are installed but exact version is requested"
                    release = find_release(mod, version:)
                    downloader.download(release, Nauvisian.platform.mods_directory + release.file_name)
                  elsif versions.all? {|v| v < version }
                    puts "↓ all versions are older than #{version}, let's download the latest"
                    # installed versions are old
                    release = find_release(mod)
                    downloader.download(release, release.file_name)
                  else
                    puts "↑ newer version exists, nothing to do"
                    # newer version exists, nothing to do
                  end
                else
                  puts "❌MOD is not installed"
                  release = options[:exact] ? find_release(mod, version:) : find_release(mod)
                  downloader.download(release, release.file_name)
                end
              end

              list = Nauvisian::ModList.new(mods_in_save.map {|mod, _version| [mod, true] })
              list.save
            end
          end
        end
      end
    end
  end
end
