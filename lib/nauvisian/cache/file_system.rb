# frozen_string_literal: true

require "digest/md5"
require "pathname"

module Nauvisian
  module Cache
    class FileSystem
      class TtlTooShort < ArgumentError; end
      class BlockRequired < ArgumentError; end

      MINIMUM_TTL = 5 * 60 # 5 minutes
      private_constant :MINIMUM_TTL

      CACHE_ROOT = Pathname(ENV.fetch("XDG_CACHE_HOME", Nauvisian.platform.home_directory / ".cache"))
      private_constant :CACHE_ROOT

      def initialize(name:, ttl: MINIMUM_TTL)
        raise TtlTooShort, ttl if ttl < MINIMUM_TTL

        @root = CACHE_ROOT / "nauvisian" / name
        @ttl = ttl
      end

      private attr_reader :root

      def fetch(key)
        raise BlockRequired unless block_given?

        path = generate_path(key)

        if path.exist?
          # If fresh cache exists, return it
          return path.binread if Time.now - path.mtime < @ttl

          # As we expect fetching content should finish within the TTL, We can safely delete the stale cache
          path.delete
        end

        # If cache does not exist, fetch the content
        dir = path.dirname
        dir.mkpath
        tmp = Tempfile.create(".cache-", dir, mode: IO::BINARY | IO::CREAT)
        content = yield
        tmp.write(content)
        tmp.close

        # Let's try opening the cache path exclusively
        path.open(IO::BINARY | IO::CREAT | IO::EXCL).close
        # if successful, we can safely store the content
        Pathname(tmp.path).rename(path)

        content
      rescue Errno::EEXIST
        Pathname(tmp).delete
        # If storing the content fails, other process/thread etc. should have created it.
        # We can read it safely.

        retry
      end

      private def generate_path(key)
        digest = Digest::MD5.hexdigest(key.to_s)
        root.join(digest[0], digest[1], digest[2..])
      end
    end
  end
end
