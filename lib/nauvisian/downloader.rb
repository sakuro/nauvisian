# frozen_string_literal: true

require "digest/sha1"
require "open-uri"

require "rack/utils"
require "ruby-progressbar"

module Nauvisian
  class Downloader
    DEFAULT_CACHE_ROOT_PATH = (Pathname(ENV.fetch("XDG_CACHE_HOME", "~/.cache")).expand_path + "nvsn/download").freeze
    private_constant :DEFAULT_CACHE_ROOT_PATH

    def initialize(credential:, cache: Nauvisian::Cache::FileSystem.new(root: DEFAULT_CACHE_ROOT_PATH))
      @credential = credential
      @cache = cache
    end

    private attr_reader :cache

    def download(release, output_path)
      @progressbar = ProgressBar.create(title: "⚙ %s" % release.file_name, format: "%t|%B|%J%%|")
      url = release.download_url.dup
      url.query = Rack::Utils.build_nested_query(@credential.to_h)
      data = cache.key?(url) ? cache[url] : get(url).tap {|content| cache[url] = content }

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
