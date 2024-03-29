# frozen_string_literal: true

require "zlib"

require "zip"

module Nauvisian
  Save = Data.define(:version, :mods, :startup_settings)

  class Save
    LEVEL_FILE_NAMES = %w(level.dat0 level-init.dat).freeze
    private_constant :LEVEL_FILE_NAMES

    LEVEL_FILE_NAMES_GLOB = File.join("*", "level{.dat0,-init.dat}")
    private_constant :LEVEL_FILE_NAMES_GLOB

    def self.load(zip_path)
      stream = stream(zip_path)
      des = Nauvisian::Deserializer.new(stream)

      new(**populate(des))
    end

    class << self
      private :new

      private def stream(zip_path)
        Zip::File.open(zip_path) do |zip_file|
          candidate_entries = zip_file.glob(LEVEL_FILE_NAMES_GLOB)
          LEVEL_FILE_NAMES.each do |file_name|
            candidate_entries.each do |entry|
              next unless File.basename(entry.name) == file_name

              stream = entry.get_input_stream
              # ZLIB Compressed Data Format Specification version 3.3
              # 2.2 Data Format https://www.rfc-editor.org/rfc/rfc1950#section-2.2
              cmf = stream.read(1).unpack1("C")
              stream.rewind
              # 32K window, deflate
              return cmf == 0x78 ? StringIO.new(Zlib.inflate(stream.read)) : stream # level.dat0 : level-init.dat
            end
          end
          raise Errno::ENOENT, "level.dat0 or level-init.dat not found"
        end
      end

      private def populate(des)
        version = des.read_version64
        raise Nauvisian::UnsupportedVersion if version < Nauvisian::Version64[1, 0, 0, 0]

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
        _loaded_from = des.read_version24
        _loaded_from_build = des.read_u16
        _allowed_commands = des.read_u8

        mods = read_mods(des)

        _unknown_4_bytes = des.read_bytes(4) # example: fPK\t (0x66 0x50 0x4B 0x09)
        startup_settings = des.read_property_tree

        {version:, mods:, startup_settings:}
      end

      private def read_mod(des)
        mod = Nauvisian::Mod[name: des.read_str.freeze]
        version = des.read_version24
        _crc = des.read_u32.freeze
        [mod, version]
      end

      private def read_mods(des) = Array.new(des.read_optim_u32) { read_mod(des) }.to_h.freeze
    end
  end
end

require_relative "deserializer"
