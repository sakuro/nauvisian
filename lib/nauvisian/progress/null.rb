# frozen_string_literal: true

module Nauvisian
  module Progress
    class Null
      def initialize(_release)
        # do nothing
      end

      def progress=(_progress)
        # do nothing
      end

      def total=(_total)
        # do nothing
      end
    end
  end
end
