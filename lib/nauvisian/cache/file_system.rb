# frozen_string_literal: true

require "digest/md5"
require "pathname"

module Nauvisian
  module Cache
    class FileSystem
      def initialize(root:, ttl: 10 * 60)
        raise TypeError unless root.is_a?(Pathname)
        raise ArgumentError unless root.exist?
        raise ArgumentError unless root.directory?

        @root = root
        @ttl = ttl
      end

      private attr_reader :root

      def key?(uri)
        path = generate_path(uri)
        path.exist? && (Time.now - path.mtime) < @ttl
      end

      def [](uri)
        return unless key?(uri)

        path = generate_path(uri)
        path.binread
      end

      def []=(uri, content)
        path = generate_path(uri)
        path.dirname.mkpath
        path.binwrite(content)
      end

      private def generate_path(uri)
        digest = Digest::MD5.hexdigest(uri.to_s)
        root.join(digest[0], digest[1], digest[2..])
      end
    end
  end
end
