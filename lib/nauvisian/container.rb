# frozen_string_literal: true

require "dry/auto_inject"
require "dry/container"
require "dry/inflector"

module Nauvisian
  extend Dry::Container::Mixin

  register "cache.api", memoize: true do
    Nauvisian.config.cache.api
  end

  register "cache.download", memoize: true do
    Nauvisian.config.cache.download
  end

  register "downloader.credential", memoize: true do
    Nauvisian.config.downloader.credential
  end

  register "downloader.progress_class", memoize: true do
    Nauvisian.config.downloader.progress_class
  end

  register "inflector", memoize: true do
    Dry::Inflector.new
  end

  Import = Dry::AutoInject(self)
  public_constant :Import
end
