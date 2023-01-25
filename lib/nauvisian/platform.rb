# frozen_string_literal: true

require "pathname"
require "rbconfig"

require "dry/inflector"

module Nauvisian
  class Platform
    def self.platform
      host_os = RbConfig::CONFIG["host_os"]
      case host_os
      when /\bdarwin\d*\b/
        MacOS.new
      when /\blinux\z/
        Linux.new
      when /\b(?:cygwin|mswin|mingw|bccwin|wince|emx)\b/
        Windows.new
      else
        raise UnsupportedPlatform, host_os
      end
    end

    def mods_directory = user_data_directory + "mods"

    def saves_directory = user_data_directory + "saves"

    def script_output_directory = user_data_directory + "script-output"

    # Returns the directory which holds user data
    def user_data_directory
      raise NotImplementedError
    end

    def application_directory
      APPLICATON_DIRECTORIES.find(&:directory?)
    end

    def name
      Nauvisian.inflector.demodulize(self.class.name).downcase.freeze
    end

    class MacOS < self
      def user_data_directory
        Pathname("~/Library/Application Support/Factorio").expand_path.freeze
      end

      APPLICATON_DIRECTORIES = [
        Pathname("~/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents").freeze,
        Pathname("/Applications/factorio.app/Contents").freeze
      ].freeze
      private_constant :APPLICATON_DIRECTORIES
    end

    class Linux < self
      def user_data_directory
        Pathname("~/.factorio").expand_path.freeze
      end

      def application_directory
        Pathname("~/.factorio").expand_path.freeze
      end
    end

    class Windows < self
      def user_data_directory
        (Pathname(ENV.fetch("APPDATA")).expand_path / "Factorio").freeze
      end

      APPLICATON_DIRECTORIES = [].freeze
      APPLICATON_DIRECTORIES << Pathname("#{ENV.fetch("PROGRAMFILES(x86)")}\\Steam\\steamapps\\common\\Factorio").freeze if ENV.key?("PROGRAMFILES(x86)")
      APPLICATON_DIRECTORIES << Pathname("#{ENV.fetch("PROGRAMFILES")}\\Factorio").freeze if ENV.key?("PROGRAMFILES")
      private_constant :APPLICATON_DIRECTORIES
    end
  end
end
