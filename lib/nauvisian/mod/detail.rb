# frozen_string_literal: true

module Nauvisian
  class Mod
    Detail = Data.define(:downloads_count, :name, :owner, :summary, :title, :category, :created_at, :description)

    class Detail
      def url = (URI("https://mods.factorio.com/mod/") + name).freeze

      class << self
        private :new
      end
    end
  end
end
