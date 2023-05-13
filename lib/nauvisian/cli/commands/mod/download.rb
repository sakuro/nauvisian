# frozen_string_literal: true

require_relative "../../download_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Download < Dry::CLI::Command
          include DownloadHelper

          desc "Download a MOD"
          argument :mod, desc: "Target MOD", required: true
          option :version, desc: "Version to download (default: latest)"
          option :user, desc: "The user at MOD Portal"
          option :token, desc: "The token at MOD Portal"

          def call(mod:, **options)
            credential = find_credential(options.slice(:user, :token))
            release = find_release(Nauvisian::Mod[name: mod], options.slice(:version))

            downloader = Nauvisian::Downloader.new(credential:, progress: Nauvisian::Progress::Bar)
            downloader.download(release, release.file_name)
          rescue => e
            puts e.message
            exit 1
          end
        end
      end
    end
  end
end
