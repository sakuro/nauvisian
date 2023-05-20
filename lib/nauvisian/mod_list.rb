# frozen_string_literal: true

require "json"

module Nauvisian
  class ModList
    DEFAULT_MOD_LIST_PATH = Nauvisian.platform.mod_directory / "mod-list.json"
    private_constant :DEFAULT_MOD_LIST_PATH

    include Enumerable

    def self.load(from=DEFAULT_MOD_LIST_PATH)
      raw_data = JSON.parse(File.read(from), symbolize_names: true)
      new(raw_data[:mods].to_h {|e| [Mod[name: e[:name]], e[:enabled]] })
    end

    def initialize(mods={})
      @mods = {Nauvisian::Mod[name: "base"] => true}
      mods.each do |mod, enabled|
        next if mod.base?

        @mods[mod] = enabled
      end
    end

    def save(to=DEFAULT_MOD_LIST_PATH)
      File.write(to, JSON.pretty_generate({mods: @mods.map {|mod, enabled| {name: mod.name, enabled:} }}))
    end

    def each
      return @mods.to_enum unless block_given?

      @mods.each do |mod, enabled|
        yield(mod, enabled)
      end
    end

    def add(mod, enabled: nil)
      raise ArgumentError, "Can't disable the base mod" if mod.base? && enabled == false

      @mods[mod] = enabled.nil? ? true : enabled
    end

    def remove(mod)
      raise ArgumentError, "Can't remove the base mod" if mod.base?

      @mods.delete(mod)
    end

    def exist?(mod) = @mods.key?(mod)

    def enabled?(mod)
      raise Nauvisian::ModNotFound, mod unless exist?(mod)

      @mods[mod]
    end

    def enable(mod)
      raise Nauvisian::ModNotFound, mod unless exist?(mod)

      @mods[mod] = true
    end

    def disable(mod)
      raise ArgumentError, "Can't disalbe the base mod" if mod.base?
      raise Nauvisian::ModNotFound, mod unless exist?(mod)

      @mods[mod] = false
    end
  end
end
