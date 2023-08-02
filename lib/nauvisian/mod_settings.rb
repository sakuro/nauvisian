# frozen_string_literal: true

require "json"

module Nauvisian
  class ModSettings
    DEFAULT_MOD_SETTINGS_PATH = Nauvisian.platform.mod_directory / "mod-settings.dat"
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

    def save(to=DEFAULT_MOD_SETTINGS_PATH)
      File.open(to, "wb") do |stream|
        ser = Nauvisian::Serializer.new(stream)
        ser.write_version64(@version)
        ser.write_bool(false)
        ser.write_property_tree(@properties)
      end
    end

    def [](key)
      @properties[key]
    end

    def []=(key, properties)
      @properties[key] = properties
    end

    def to_json(*)
      JSON.generate(@properties.merge(version: @version), *)
    end
  end
end
