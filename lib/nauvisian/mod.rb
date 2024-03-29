# frozen_string_literal: true

module Nauvisian
  Mod = Data.define(:name) do
    include Comparable

    def base?
      name == "base"
    end

    def to_s = name

    def <=>(other)
      (base? && (other.base? ? 0 : -1)) || (other.base? ? 1 : name.casecmp(other.name))
    end
  end
end

require_relative "mod/detail"
require_relative "mod/release"
