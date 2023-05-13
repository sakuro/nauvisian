# frozen_string_literal: true

require "ruby-progressbar"

module Nauvisian
  module Progress
    class Bar
      FORMAT = "%t|%B|%J%%|"
      private_constant :FORMAT

      def initialize(release)
        @progress_bar = ProgressBar.create(title: release.file_name, format: FORMAT)
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
