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
            option :verbose, desc: "Print extra information", type: :boolean, default: false
            option :mods_directory, desc: "The directory where MODs are installed", default: Nauvisian.platform.mods_directory

            def call(save_file:, **options)
              save_file_path = Pathname(save_file)
              save = Nauvisian::Save.load(save_file_path)
              mods_in_save = save.mods.sort # [[mod, version]]

              existing_mods = ExistingMods.new(**options)

              downloader = Nauvisian::Downloader.new(credential: find_credential, progress: options[:verbose] ? Nauvisian::Progress::Bar : Nauvisian::Progress::Null)

              mods_in_save.each do |mod, version|
                next if mod.base?

                release = existing_mods.release_to_download(mod, version)
                next unless release

                downloader.download(release, options[:mods_directory] + release.file_name)
              end

              list = Nauvisian::ModList.new(mods_in_save.map {|mod, _version| [mod, true] })
              list.save
            end

            class ExistingMods
              include DownloadHelper

              def initialize(mods_directory:, exact: false, verbose: false)
                @exact = exact
                @verbose = verbose

                zips = mods_directory.glob("*.zip")
                directories = mods_directory.entries.select(&:directory?)
                # [[mod, [version...]]
                @mods = [*zips, *directories].filter_map {|path|
                  /(?<name>.*)_(?<version>\d+\.\d+\.\d+)(?:\.zip|$)\z/ =~ path.basename.to_s && [Nauvisian::Mod[name:], Nauvisian::Version24[version]]
                }.group_by(&:first).transform_values {|v| v.map(&:last) }.to_a
              end

              def exact? = @exact
              def verbose? = @verbose

              def release_to_download(mod, version)
                print "Checking #{mod.name} #{version} ... " if verbose?

                case @mods
                in [*, [^mod, [*, ^version, *]], *]
                  puts "✓ Exact version exists, nothing to do" if verbose?
                in [*, [^mod, [*versions]], *]
                  if exact?
                    puts "↓ some versions are installed but exact version is requested" if verbose?
                    find_release(mod, version:)
                  elsif versions.all? {|v| v < version }
                    puts "↓ all versions are older than #{version}, let's download the latest" if verbose?
                    find_release(mod)
                  else
                    puts "↑ newer version exists, nothing to do" if verbose?
                  end
                else
                  puts "❌MOD is not installed" if verbose?
                  exact? ? find_release(mod, version:) : find_release(mod)
                end
              end
            end
          end
        end
      end
    end
  end
end
