# frozen_string_literal: true

module Nauvisian
  module Progress
    class Null
      def initialize(**options)
        # do nothing
      end

      def progress=(progress)
        # do nothing
      end

      def total=(total)
        # do nothing
      end
    end
  end
end
