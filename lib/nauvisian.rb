# frozen_string_literal: true

require "dry/inflector"

require_relative "nauvisian/api"
require_relative "nauvisian/credential"
require_relative "nauvisian/deserializer"
require_relative "nauvisian/downloader"
require_relative "nauvisian/mod"
require_relative "nauvisian/platform"
require_relative "nauvisian/progress"
require_relative "nauvisian/save"
require_relative "nauvisian/serializer"
require_relative "nauvisian/version"
require_relative "nauvisian/version24"
require_relative "nauvisian/version64"

module Nauvisian
  class Error < StandardError; end
  class NotFound < Error; end
  class AuthError < Error; end
  class DigestError < Error; end
  class TooManyRedirections < Error; end
  class UnsupportedPlatform < Error; end
  class UnknownPropertyType < Error; end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end

  def self.platform
    @platform ||= Nauvisian::Platform.platform
  end
end

# some class must be loaded after definine Nauvisian::Platform.platform
require_relative "nauvisian/cache"
require_relative "nauvisian/mod_list"
require_relative "nauvisian/mod_settings"
