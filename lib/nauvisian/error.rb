# frozen_string_literal: true

module Nauvisian
  class Error < StandardError; end
  class ModNotFound < Error; end
  class AuthError < Error; end
  class DigestError < Error; end
  class UnsupportedPlatform < Error; end
  class UnsupportedVersion < Error; end
  class UnknownPropertyType < Error; end
end
