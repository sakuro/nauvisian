# frozen_string_literal: true

require "rack/utils"
require "ruby-progressbar"

require "digest/sha1"
require "open-uri"

module Nauvisian
  class Downloader
    def initialize(credential)
      @credential = credential
    end

    def download(release, output_path)
      @progressbar = ProgressBar.create(title: "⚙ %s" % release.file_name, format: "%t|%B|%J%%|")
      url = release.download_url.dup
      url.query = Rack::Utils.build_nested_query(@credential.to_h)
      data = get(url)
      File.binwrite(output_path, data)
      raise DigestError, "Digest mismatch" unless Digest::SHA1.file(output_path) == release.sha1
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
    rescue OpenURI::HTTPError => e
      case e.io.status
      in ["404", _]
        raise Nauvisian::NotFound
      else
        raise Nauvisian::Error
      end
    end

    private def set_total(total) # rubocop:disable Naming/AccessorMethodName
      @progressbar.total = total if total
    end

    private def update_progress(progress)
      @progressbar.progress = progress
    end
  end
end
