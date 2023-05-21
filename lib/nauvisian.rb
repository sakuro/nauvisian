# frozen_string_literal: true

require "dry/configurable"

require_relative "nauvisian/error"

require_relative "nauvisian/credential"
require_relative "nauvisian/deserializer"
require_relative "nauvisian/mod"
require_relative "nauvisian/platform"
require_relative "nauvisian/progress"
require_relative "nauvisian/save"
require_relative "nauvisian/serializer"
require_relative "nauvisian/version"
require_relative "nauvisian/version24"
require_relative "nauvisian/version64"

module Nauvisian
  def self.platform
    @platform ||= Nauvisian::Platform.platform
  end
end

# some class must be loaded after definine Nauvisian::Platform.platform
require_relative "nauvisian/cache"
require_relative "nauvisian/mod_list"
require_relative "nauvisian/mod_settings"

module Nauvisian
  extend Dry::Configurable

  setting :cache do
    setting :api, default: Nauvisian::Cache::FileSystem.new(name: "api", ttl: 10 * 60 * 60)
    setting :download, default: Nauvisian::Cache::FileSystem.new(name: "download", ttl: 10 * 60 * 60)
  end
  setting :downloader do
    setting :credential, default: Nauvisian::Credential.from_env
    setting :progress_class, default: Nauvisian::Progress::Bar
  end
end

require_relative "nauvisian/container"

# these classes rely on the container
require_relative "nauvisian/api"
require_relative "nauvisian/downloader"
