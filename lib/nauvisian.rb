# frozen_string_literal: true

require_relative "nauvisian/api"
require_relative "nauvisian/credential"
require_relative "nauvisian/deserializer"
require_relative "nauvisian/downloader"
require_relative "nauvisian/mod"
require_relative "nauvisian/mod_list"
require_relative "nauvisian/mod_settings"
require_relative "nauvisian/platform"
require_relative "nauvisian/save"
require_relative "nauvisian/version"
require_relative "nauvisian/version24"
require_relative "nauvisian/version64"

require "dry/inflector"

module Nauvisian
  class Error < StandardError; end
  class NotFound < Error; end
  class AuthError < Error; end
  class DigestError < Error; end
  class TooManyRedirections < Error; end
  class UnsupportedPlatform < Error; end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end
end
