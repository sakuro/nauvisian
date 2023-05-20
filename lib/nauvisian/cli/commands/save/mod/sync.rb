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

            option :mod_directory, desc: "Directory where MODs are installed", required: false, default: Nauvisian.platform.mod_directory.to_s
            option :exact, desc: "Use exact version", type: :boolean, default: false
            option :verbose, desc: "Print extra information", type: :boolean, default: false

            def call(save_file:, **options)
              save_file_path = Pathname(save_file)
              save = Nauvisian::Save.load(save_file_path)
              mods_in_save = save.mods.sort # [[mod, version]]

              options[:mod_directory] = Pathname(options[:mod_directory])
              existing_mods = ExistingMods.new(**options)

              downloader = Nauvisian::Downloader.new(credential: find_credential, progress: options[:verbose] ? Nauvisian::Progress::Bar : Nauvisian::Progress::Null)

              mods_in_save.each do |mod, version|
                next if mod.base?

                release = existing_mods.release_to_download(mod, version)
                next unless release

                downloader.download(release, options[:mod_directory] / release.file_name)
              end

              list = Nauvisian::ModList.new(mods_in_save.map {|mod, _version| [mod, true] })
              list.save(options[:mod_directory] / "mod-list.json")

              settings = Nauvisian::ModSettings.load(options[:mod_directory] / "mod-settings.dat")
              settings["startup"] = save.startup_settings
              settings.save(options[:mod_directory] / "mod-settings.dat")
            rescue => e
              puts e.message
              exit 1
            end

            class ExistingMods
              include DownloadHelper

              def initialize(mod_directory:, exact:, verbose:)
                @exact = exact
                @verbose = verbose

                zips = mod_directory.glob("*.zip")
                directories = mod_directory.entries.select(&:directory?)
                # [[mod, [version...]]
                @mods = [*zips, *directories].filter_map {|path|
                  /(?<name>.*)_(?<version>\d+\.\d+\.\d+)(?:\.zip|$)\z/ =~ path.basename.to_s && [Nauvisian::Mod[name:], Nauvisian::Version24[version]]
                }.group_by(&:first).transform_values {|v| v.map(&:last) }.to_a
              end

              def exact? = @exact
              def verbose? = @verbose

              def log(message, newline: true)
                return unless verbose?

                if newline
                  puts message
                else
                  print message
                end
              end

              def release_to_download(mod, version)
                log "⚙ Checking #{mod.name} #{version} ... ", newline: false

                case @mods
                in [*, [^mod, [*, ^version, *]], *]
                  log "✓ Exact version exists, nothing to do"
                in [*, [^mod, [*versions]], *]
                  if exact?
                    log "📥 some versions are installed but exact version is requested"
                    find_release(mod, version:)
                  elsif versions.all? {|v| v < version }
                    log "📥 all versions are older than #{version}, let's download the latest"
                    find_release(mod)
                  else
                    log "✓ newer version exists, nothing to do"
                  end
                else
                  log "❌ MOD is not installed"
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
