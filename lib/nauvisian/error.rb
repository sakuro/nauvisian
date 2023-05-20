# frozen_string_literal: true

module Nauvisian
  class Error < StandardError; end

  class ModNotFound < Error
    def initialize(mod) = super "Mod not found: #{mod.name}"
  end

  class AuthError < Error; end
  class APIError < Error; end
  class DigestMismatch < Error; end
  class UnsupportedPlatform < Error; end
  class UnsupportedVersion < Error; end
  class UnknownPropertyType < Error; end
end
