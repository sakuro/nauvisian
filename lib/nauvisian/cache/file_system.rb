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

        if path.exist?
          # Fresh cache exists, return it
          return path.binread unless stale?(path, Time.now)

          # As we expect fetching content should finish within the TTL, we can safely delete the stale cache here
          path.delete
        end

        # Cache does not exist, fetch the content
        content = yield
        store(path, content)
        content
      rescue Errno::EEXIST
        # We can read it safely next time.
        retry
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

        # Let's try opening the desired cache path exclusively
        path.open(IO::BINARY | IO::CREAT | IO::EXCL).close

        # If successful, we can safely rename
        tmp_path = Pathname(tmp)
        tmp_path.rename(path)
      rescue Errno::EEXIST
        # In case the desired path already has a file, other process/thread etc. should have created it.
        tmp_path.delete
        raise
      end
    end
  end
end
