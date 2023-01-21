# frozen_string_literal: true

module Nauvisian
  Mod = Data.define(:name) # rubocop:disable Style/ConstantVisibility
end

require_relative "mod/detail"
require_relative "mod/release"
require_relative "mod/version"
