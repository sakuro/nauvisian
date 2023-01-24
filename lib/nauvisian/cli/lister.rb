# frozen_string_literal: true

require "json"

module Nauvisian
  module CLI
    class Lister
      @listers = {}

      def self.for(format)
        @listers.fetch(format)
      end

      def self.inherited(subclass)
        demodulized = Nauvisian.inflector.demodulize(subclass.name)
        underscored = Nauvisian.inflector.underscore(demodulized)
        @listers[underscored.to_sym] = subclass

        super
      end

      def initialize(headers)
        @headers = headers
      end

      class CSV < self
        def list(rows)
          CSV(headers: @headers, write_headers: true) do |out|
            rows.each do |row|
              out << row.values_at(*@headers)
            end
          end
        end
      end

      class Gfm < self
        def list(rows)
          puts @headers.join("|")
          puts Array.new(@headers.length, "-").join("|")
          rows.each do |row|
            puts row.values_at(*@headers).join("|")
          end
        end
      end

      class Plain < self
        def list(rows)
          rows.each do |row|
            puts row.values_at(*@headers).join(" ")
          end
        end
      end

      class Json < self
        def list(rows)
          puts rows.to_json
        end
      end
    end
  end
end
