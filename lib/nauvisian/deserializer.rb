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

    def read_optim_u16 = read_optim(16)
    def read_optim_u32 = read_optim(32)

    def read_u16_tuple(length) = Array.new(length) { read_u16 }
    def read_optim_tuple(bit_size, length) = Array.new(length) { read_optim(bit_size) }

    def read_bool = read_u8 != 0

    def read_str
      length = read_optim_u32
      read_bytes(length).force_encoding(Encoding::UTF_8)
    end

    def read_str_property = read_bool ? "" : read_str

    def read_double = read_bytes(8).unpack1("d")

    # Assumed: method arguments are evaluated from left to right but...
    # https://stackoverflow.com/a/36212870/16014712

    def read_version64 = Nauvisian::Version64[read_u16, read_u16, read_u16, read_u16]

    def read_version24 = Nauvisian::Version24[read_optim_u32, read_optim_u32, read_optim_u32]

    def read_list
      length = read_optim_u32
      Array(length) { read_property_tree }
    end

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

    private def read_optim(bit_size)
      raise ArgumentError, "invalid bit size" unless bit_size == 16 || bit_size == 32

      byte = read_u8
      return byte unless byte == 0xFF

      case bit_size
      when 16
        read_u16
      when 32
        read_u32
      else
        raise ArgumentError, "Wrong bit_size (must be 16 or 32)"
      end
    end
  end
end
