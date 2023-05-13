# frozen_string_literal: true

module Nauvisian
  module CLI
    module Commands
      module Mod
        class Download < Dry::CLI::Command
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

          private def find_credential(credential_options)
            case credential_options
            in {user:, token:}
              return Nauvisian::Credential[user:, token:]
            in {user:}
              puts "User is specified, but token is missing"
              exit 1
            in {token:}
              puts "Token is specified, but user is missing"
              exit 1
            else
              Nauvisian::Credential.from_env
            end
          rescue KeyError
            Nauvisian::Credential.from_player_data_file
          end

          private def find_release(mod, version_options)
            api = Nauvisian::API.new
            releases = api.releases(mod)
            if version_options[:version].nil? || version_options[:version] == "latest"
              releases.max_by(&:released_at)
            else
              version24 = Nauvisian::Version24[version_options[:version]]
              if_none = -> { puts "Version: #{version24} not found"; exit 1 }
              releases.find(if_none) {|release| release.version == version24 }
            end
          end
        end
      end
    end
  end
end