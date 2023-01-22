# frozen_string_literal: true

require "ruby-progressbar"
require "rack/utils"

require "digest/sha1"
require "open-uri"

module Nauvisian
  class Downloader
    def initialize(credential)
      @credential = credential
    end

    def download(release, output_path)
      url = release.download_url.dup
      url.query = Rack::Utils.build_nested_query(@credential.to_h)
      progressbar = ProgressBar.create(title: "⚙ %s" % release.file_name, format: "%t|%B|%J%%|")
      data = get(url, progressbar)
      File.binwrite(output_path, data)
      raise DigestError, "Digest mismatch" unless Digest::SHA1.file(output_path) == release.sha1
    end

    private def get(url, progressbar)
      url.open(
        content_length_proc: ->(length_str) { progressbar.total = length_str.to_i if length_str },
        progress_proc: ->(progress) { progressbar.progress = progress }
      ) do |io|
        case io.content_type
        when "application/octet-stream"
          return io.read
        else # login requested
          raise Nauvisian::AuthError, io.status[1]
        end
      end
    rescue OpenURI::HTTPError => e
      case e.io.status
      in ["404", _]
        raise Nauvisian::NotFound
      else
        raise Nauvisian::Error
      end
    rescue Nauvisian::AuthError
      raise
    end
  end
end
