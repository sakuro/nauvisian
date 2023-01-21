# frozen_string_literal: true

module Nauvisian
  Mod = Data.define(:name) do # rubocop:disable Style/ConstantVisibility
    def base?
      name == "base"
    end
  end
end

require_relative "mod/detail"
require_relative "mod/release"
require_relative "mod/version"
