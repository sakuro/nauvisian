# frozen_string_literal: true

require "dry/inflector"

require "pathname"

module Nauvisian
  class Platform
    def self.platform
      @platform ||=
        case RUBY_PLATFORM
        when /\bdarwin\b/
          MacOS.new
        when /\b-linux\z/
          Linux.new
        when /\b(?:cygwin|mswin|mingw|bccwin|wince|emx)\b/
          Windows.new
        else
          raise Unsupported, RUBY_PLATFORM
        end
    end

    def self.user_data_directory = platform.user_data_directory
    def self.application_directory = platform.application_directory

    def self.mods_directory = user_data_directory + "mods"
    def self.saves_directory = user_data_directory + "saves"
    def self.script_output_directory = user_data_directory + "script-output"

    # Returns the directory which holds user data
    def user_data_directory
      raise NotImplementedError
    end

    def application_directory
      APPLICATON_DIRECTORIES.find(&:directory?)
    end

    def name
      inflector = Dry::Inflector.new
      inflector.demodulize(self.class.name).downcase
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

      APPLICATON_DIRECTORIES = [
        Pathname("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Factorio").freeze,
        Pathname("C:\\Program Files\\Factorio").freeze
      ].freeze
      private_constant :APPLICATON_DIRECTORIES
    end
  end
end
