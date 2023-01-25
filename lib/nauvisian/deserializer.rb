# frozen_string_literal: true

module Nauvisian
  class Deserializer
    def initialize(stream)
      raise ArgumentError, "can't read from the given argument" unless stream.respond_to?(:read)

      @stream = stream
    end

    def read_bytes(length)
      case length
      in Integer if length.negative?
        raise ArgumentError, "Negative length"
      in 0
        return +""
      in nil
        @stream.read(length)
      else
        bytes = @stream.read(length)
        raise EOFError if @stream.eof? && (bytes.nil? || (bytes.length < length))

        bytes
      end
    end

    def read_u8 = read_bytes(1).unpack1("C")
    def read_u16 = read_bytes(2).unpack1("v")
    def read_u32 = read_bytes(4).unpack1("V")

    # https://wiki.factorio.com/Data_types#Space_Optimized
    def read_optim_u16
      byte = read_u8
      byte == 0xFF ? read_u16 : byte
    end

    # https://wiki.factorio.com/Data_types#Space_Optimized
    def read_optim_u32
      byte = read_u8
      byte == 0xFF ? read_u32 : byte
    end

    def read_u16_tuple(length) = Array.new(length) { read_u16 }
    def read_optim_tuple(bit_size, length) = Array.new(length) { read_optim(bit_size) }

    def read_bool = read_u8 != 0

    def read_str
      length = read_optim_u32
      read_bytes(length).force_encoding(Encoding::UTF_8)
    end

    # https://wiki.factorio.com/Property_tree#String
    def read_str_property = read_bool ? "" : read_str

    # https://wiki.factorio.com/Property_tree#Number
    def read_double = read_bytes(8).unpack1("d")

    # Assumed: method arguments are evaluated from left to right but...
    # https://stackoverflow.com/a/36212870/16014712

    def read_version64 = Nauvisian::Version64[read_u16, read_u16, read_u16, read_u16]

    def read_version24 = Nauvisian::Version24[read_optim_u16, read_optim_u16, read_optim_u16]

    # https://wiki.factorio.com/Property_tree#List
    def read_list
      length = read_optim_u32
      Array(length) { read_property_tree }
    end

    # https://wiki.factorio.com/Property_tree#Dictionary
    def read_dictionary
      length = read_u32
      length.times.each_with_object({}) do |_i, dict|
        key = read_str_property
        dict[key] = read_property_tree
      end
    end

    def read_property_tree
      type = read_u8
      _any_type_flag = read_bool

      case type
      when 1
        read_bool
      when 2
        read_double
      when 3
        read_str_property
      when 4
        read_list
      when 5
        read_dictionary
      else
        raise "unknown property type: %p" % type
      end
    end
  end
end
