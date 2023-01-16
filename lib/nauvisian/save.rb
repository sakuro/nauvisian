# frozen_string_literal: true

require "zlib"

require "zip"

module Nauvisian
  Save = Data.define(:version, :mods) # rubocop:disable Style/ConstantVisibility

  class Save
    LEVEL_FILE_NAMES = %w(level.dat0 level-init.dat)
    private_constant :LEVEL_FILE_NAMES
    LEVEL_FILE_NAMES_GLOB = File.join("*", "level{.dat0,-init.dat}")
    private_constant :LEVEL_FILE_NAMES_GLOB

    def self.load(zip_path)
      stream = stream(zip_path)
      des = Nauvisian::Save::Deserializer.new(stream)
      new(**populate(des))
    end

    class << self
      private :new
      private def stream(zip_path)
        Zip::File.open(zip_path) do |zip_file|
          candidate_entries = zip_file.glob(LEVEL_FILE_NAMES_GLOB)
          LEVEL_FILE_NAMES.each do |file_name|
            candidate_entries.each do |entry|
              if File.basename(entry.name) == file_name
                stream = entry.get_input_stream
                # ZLIB Compressed Data Format Specification version 3.3
                # 2.2 Data Format https://www.rfc-editor.org/rfc/rfc1950#section-2.2
                cmf = stream.read(1).unpack1("C")
                stream.rewind
                if cmf == 0x78 # 32K window, deflate
                  # level.dat0
                  return StringIO.new(Zlib.inflate(stream.read))
                else
                  # level-init.dat
                  return stream
                end
            end
            end
          end
          raise Errno::ENOENT, "No initial level file"
        end
      end

      private def populate(des)
        version = read_save_version(des)
        raise ArgumentError, "Unsupported version" if version < Nauvisian::Save::Version[1, 0, 0, 0]

        des.read_u8 # skip a byte

        # Some values are out of concern
        _campaign = des.read_str
        _level_name = des.read_str
        _base_mod = des.read_str
        _difficulty = des.read_u8
        _finished = des.read_bool
        _player_won = des.read_bool
        _next_level = des.read_str
        _can_continue = des.read_bool
        _finished_but_continuing = des.read_bool
        _saving_replay = des.read_bool
        _allow_non_admin_debug_options = des.read_bool
        _loaded_from = read_mod_version(des)
        _loaded_from_build = des.read_u16
        _allowed_commands = des.read_u8
        { version:, mods: read_mods(des) }
      end

      private def read_save_version(des)
        Nauvisian::Save::Version[des.read_u16, des.read_u16, des.read_u16, des.read_u16]
      end

      private def read_mod_version(des)
        # Assumed: method arguments are evaluated from left to right but...
        # https://stackoverflow.com/a/36212870/16014712
        Nauvisian::Mod::Version[des.read_optim_u32, des.read_optim_u32, des.read_optim_u32]
      end

      private def read_mod(des)
        # Assumed: method arguments are evaluated from left to right but...
        # https://stackoverflow.com/a/36212870/16014712
        Nauvisian::Mod[name: des.read_str.freeze, version: read_mod_version(des), crc: des.read_u32.freeze]
      end

      private def read_mods(des)
        Array.new(des.read_optim_u32) { read_mod(des) }.freeze
      end
    end
  end
end

require_relative "save/deserializer"
require_relative "save/version"
