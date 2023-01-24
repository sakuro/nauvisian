# frozen_string_literal: true

require "nauvisian/platform"

require "json"

module Nauvisian
  class ModSettings
    DEFAULT_MOD_SETTINGS_PATH = Nauvisian::Platform.mods_directory / "mod-settings.dat"
    private_constant :DEFAULT_MOD_SETTINGS_PATH

    def self.load(from=DEFAULT_MOD_SETTINGS_PATH)
      File.open(from, "rb") do |stream|
        des = Nauvisian::Deserializer.new(stream)
        version = des.read_version64
        _unused = des.read_bool
        properties = des.read_property_tree
        new(version:, properties:)
      end
    end

    def initialize(version:, properties:)
      @version = version
      @properties = properties
    end

    def [](key)
      @properties[key]
    end

    def to_json
      @properties.to_json
    end
  end
end
