# frozen_string_literal: true

require "digest/md5"
require "pathname"

module Nauvisian
  module Cache
    class FileSystem
      MINIMUM_TTL = 5 * 60 # 5 minutes
      private_constant :MINIMUM_TTL

      def self.cache_root
        Pathname(ENV.fetch("XDG_CACHE_HOME", Nauvisian.platform.home_directory / ".cache")) / "nauvisian"
      end

      def initialize(name:, ttl: MINIMUM_TTL)
        raise ArgumentError, "ttl is too small (must be >= #{MINIMUM_TTL})" if ttl < MINIMUM_TTL

        @cache_directory = self.class.cache_root / name
        @ttl = ttl
      end

      private attr_reader :root

      def fetch(key)
        path = generate_path(key)
        return path.binread if path.exist? && !stale?(path, Time.now)

        yield.tap {|content| store(path, content) }
      end

      private def generate_path(key)
        digest = Digest::MD5.hexdigest(key.to_s)
        @cache_directory.join(digest[0], digest[1], digest[2..])
      end

      private def stale?(path, time)
        time - path.mtime > @ttl
      end

      private def store(path, content)
        dir = path.dirname
        dir.mkpath

        # Store into a temporary file
        tmp = Tempfile.create(".cache-", dir, mode: IO::BINARY | IO::CREAT)
        tmp.write(content)
        tmp.close

        # Rename to the desired path
        File.rename(tmp.path, path)
      end
    end
  end
end
