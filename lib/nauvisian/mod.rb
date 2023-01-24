# frozen_string_literal: true

module Nauvisian
  Mod = Data.define(:name) do
    include Comparable

    def base?
      name == "base"
    end

    def <=>(other)
      name.casecmp(other.name)
    end
  end
end

require_relative "mod/detail"
require_relative "mod/release"
