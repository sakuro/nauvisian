# frozen_string_literal: true

require "nauvisian"

require "dry/cli"

module Nauvisian
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class DownloadMatchingMods < Dry::CLI::Command
        desc "Download Mods matching the given save file"
        argument :save, desc: "Save file of a Factorio game"

        def call(save:, **)
          downloader = Nauvisian::Downloader.new(Nauvisian::Credential.from_env)

          save = Nauvisian::Save.load(save)
          api = Nauvisian::API.new
          mods = save.mods
          mods.each do |mod, version|
            next if mod.base?

            _detail = api.detail(mod)
            releases = api.releases(mod)
            release = releases.find {|rel| rel.version == version }

            downloader.download(release, File.join(Dir.pwd, release.file_name))
          end
        end
      end

      register "download-matching-mods", DownloadMatchingMods
    end
  end
end
