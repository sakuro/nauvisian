# frozen_string_literal: true

require_relative "nauvisian/api"
require_relative "nauvisian/credential"
require_relative "nauvisian/downloader"
require_relative "nauvisian/mod"
require_relative "nauvisian/save"
require_relative "nauvisian/version"

module Nauvisian
  class Error < StandardError; end
  class NotFound < Error; end
  class AuthError < Error; end
  class DigestError < Error; end
  class TooManyRedirections < Error; end
end
