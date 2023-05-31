# frozen_string_literal: true

require_relative "../../download_helper"
require_relative "../../message_helper"

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Download < Dry::CLI::Command
          include DownloadHelper
          include MessageHelper

          desc "Download a MOD to the current directory"
          argument :mod, desc: "Target MOD", required: true
          option :version, desc: "Version to download (default: latest)"
          option :user, desc: "The user at MOD Portal"
          option :token, desc: "The token at MOD Portal"

          def call(mod:, **options)
            credential = find_credential(**options.slice(:user, :token))
            release = find_release(Nauvisian::Mod[name: mod], version: options.key?(:version) ? Nauvisian::Version24[options[:version]] : nil)

            downloader = Nauvisian::Downloader.new(credential:, progress_class: Nauvisian::Progress::Bar)
            downloader.download(release, release.file_name)
          rescue => e
            message(e)
            exit 1
          end
        end
      end
    end
  end
end
