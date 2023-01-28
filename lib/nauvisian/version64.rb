# frozen_string_literal: true

module Nauvisian
  class Version64
    include Comparable

    UINT16_MAX = (2**16) - 1
    private_constant :UINT16_MAX

    def initialize(*args)
      case args
      in [String] if /\A(\d+)\.(\d+)\.(\d+)(?:-(\d+))?\z/ =~ args[0]
        @version = [Integer($1), Integer($2), Integer($3), $4.nil? ? 0 : Integer($4)]
      in [Integer, Integer, Integer, Integer] if args.all? {|e| e.is_a?(Numeric) && e.integer? && e.between?(0, UINT16_MAX) }
        @version = args
      else
        raise ArgumentError, "Expect version string or 4-tuple: %p" % [args]
      end
      @version.freeze
      freeze
    end

    class << self
      alias [] new
    end

    protected attr_reader :version

    def to_s = "%d.%d.%d-%d" % @version
    def to_a = @version.dup.freeze
    def <=>(other) = @version <=> other.version
  end
end
