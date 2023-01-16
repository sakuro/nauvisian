# frozen_string_literal: true

module Nauvisian
  class Mod
    class Version
      include Comparable

      UINT8_MAX = (2**8) - 1
      private_constant :UINT8_MAX

      def initialize(*args)
        case args
        in [String] if /\A(\d+)\.(\d+)\.(\d+)\z/ =~ args[0]
          @version = [Integer($1), Integer($2), Integer($3)]
        in [Integer, Integer, Integer] if args.all? {|e| e.is_a?(Numeric) && e.integer? && e.between?(0, UINT8_MAX) }
          @version = args
        else
          raise ArgumentError, "Expect version string or 3-tuple: %p" % [args]
        end
        @version.freeze
        freeze
      end

      class << self
        alias [] new
      end

      protected attr_reader :version

      def to_s
        "%d.%d.%d" % @version
      end

      def <=>(other)
        @version <=> other.version
      end
    end
  end
end
