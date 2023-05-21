# frozen_string_literal: true

require "dry/auto_inject"
require "dry/container"

module Nauvisian
  class Container
    extend Dry::Container::Mixin
    register "cache.api" do
      Nauvisian.config.cache.api
    end

    register "cache.download" do
      Nauvisian.config.cache.download
    end

    register "downloader.credential" do
      Nauvisian.config.downloader.credential
    end

    register "downloader.progress_class" do
      Nauvisian.config.downloader.progress_class
    end
  end

  Import = Dry::AutoInject(Nauvisian::Container)
  public_constant :Import
end
