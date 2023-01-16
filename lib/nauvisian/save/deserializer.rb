# frozen_string_literal: true

module Nauvisian
  class Save
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

      def read_u8
        read_bytes(1).unpack1("C") # uint8
      end

      def read_u16
        read_bytes(2).unpack1("v") # little endian uint16
      end

      def read_u32
        read_bytes(4).unpack1("V") # little endian uint32
      end

      def read_optim_u16
        read_optim(16)
      end

      def read_optim_u32
        read_optim(32)
      end

      def read_u16_tuple(length)
        Array.new(length) { read_u16 }
      end

      def read_optim_tuple(bit_size, length)
        Array.new(length) { read_optim(bit_size) }
      end

      def read_bool
        read_u8 != 0
      end

      def read_str
        length = read_optim_uint32
        read_bytes(length).force_encoding(Encoding::UTF_8)
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
end
