# frozen_string_literal: true

require "digest/sha1"
require "open-uri"

require "rack/utils"

require "nauvisian"

module Nauvisian
  class Downloader
    include Import["downloader.credential", "downloader.progress_class", cache: "cache.download"]

    def download(release, output_path)
      with_error_handling(release) do
        @progress = @progress_class.new(release)
        url = release.download_url.dup
        url.query = Rack::Utils.build_nested_query(@credential.to_h)
        data = @cache.fetch(url) { get(url) }
        File.binwrite(output_path, data)
        raise Nauvisian::DigestMismatch unless Digest::SHA1.file(output_path) == release.sha1
      end
    end

    private def with_error_handling(release)
      yield
    rescue OpenURI::HTTPError => e
      case e.io.status
      in ["404", _]
        raise Nauvisian::ModNotFound, release.mod
      else
        raise Nauvisian::Error
      end
    end

    private def get(url)
      url.open(content_length_proc: method(:set_total), progress_proc: method(:update_progress)) do |io|
        case io.content_type
        when "application/octet-stream"
          return io.read
        else # login requested
          raise Nauvisian::AuthError, io.status[1]
        end
      end
    end

    private def set_total(total) # rubocop:disable Naming/AccessorMethodName
      @progress.total = total if total
    end

    private def update_progress(progress)
      @progress.progress = progress
    end
  end
end
