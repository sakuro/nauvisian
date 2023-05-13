# frozen_string_literal: true

require "ruby-progressbar"

module Nauvisian
  module Progress
    class Bar
      DEFAULT_OPTIONS = {
        format: "%t|%B|%J%%|",
        title: "⚙"
      }.freeze
      private_constant :DEFAULT_OPTIONS

      def initialize(**options)
        @progress_bar = ProgressBar.create(**DEFAULT_OPTIONS.merge(options))
      end

      def progress=(progress)
        @progress_bar.progress = progress
      end

      def total=(total)
        @progress_bar.total = total
      end
    end
  end
end
