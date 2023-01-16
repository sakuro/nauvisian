# frozen_string_literal: true

module Nauvisian
  Mod = Data.define(:name, :version, :crc) # rubocop:disable Style/ConstantVisibility
end

require_relative "mod/version"
