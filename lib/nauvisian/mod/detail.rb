# frozen_string_literal: true

module Nauvisian
  class Mod
    Detail = Data.define(:downloads_count, :name, :owner, :summary, :title, :category)

    class Detail
      class << self
        private :new
      end
    end
  end
end
