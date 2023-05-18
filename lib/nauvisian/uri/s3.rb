# frozen_string_literal: true

require "uri"

module Nauvisian
  module URI
    class S3 < ::URI::Generic
      DEFAULT_PORT = nil
      private_constant :DEFAULT_PORT

      def key = path.delete_prefix("/").freeze

      def key=(key)
        self.path = "/#{key}"
      end

      alias bucket host
    end
  end
end

URI.register_scheme "S3", Nauvisian::URI::S3
