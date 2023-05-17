# frozen_string_literal: true

module Nauvisian
  class Serializer
    def initialize(stream)
      raise ArgumentError, "can't read from the given argument" unless stream.respond_to?(:write)

      @stream = stream
    end

    def write_bytes(data)
      raise ArgumentError if data.nil?
      return if data.empty?

      @stream.write(data)
    end

    def write_u8(uint8) = write_bytes([uint8].pack("C"))
    def write_u16(uint16) = write_bytes([uint16].pack("v"))
    def write_u32(uint32) = write_bytes([uint32].pack("V"))

    # https://wiki.factorio.com/Data_types#Space_Optimized
    def write_optim_u16(uint16)
      if uint16 < 0xFF
        write_u8(uint16 & 0xFF)
      else
        write_u8(0xFF)
        write_u16(uint16)
      end
    end

    # https://wiki.factorio.com/Data_types#Space_Optimized
    def write_optim_u32(uint32)
      if uint32 < 0xFF
        write_u8(uint32 & 0xFF)
      else
        write_u8(0xFF)
        write_u32(uint32)
      end
    end

    # def read_u16_tuple(length) = Array.new(length) { read_u16 }
    # def read_optim_tuple(bit_size, length) = Array.new(length) { read_optim(bit_size) }

    def write_bool(bool) = write_u8(bool ? 0x01 : 0x00)

    def write_str(str)
      write_optim_u32(str.length)
      write_bytes(str.b)
    end

    # https://wiki.factorio.com/Property_tree#String
    def write_str_property(str)
      if str.empty?
        write_bool(true)
      else
        write_bool(false)
        write_str(str)
      end
    end

    # https://wiki.factorio.com/Property_tree#Number
    def write_double(dbl) = write_bytes([dbl].pack("d"))

    def write_version64(v64) = v64.to_a.each {|u16| write_u16(u16) }

    def write_version24(v24) = v24.to_a.each {|u16| write_optim_u16(u16) }

    # https://wiki.factorio.com/Property_tree#List
    def write_list(list)
      write_optim_u32(list.size)
      list.each {|e| write_property_tree(e) }
    end

    # https://wiki.factorio.com/Property_tree#Dictionary
    def write_dictionary(dict)
      write_u32(dict.size)
      dict.each do |(key, value)|
        write_str_property(key)
        write_property_tree(value)
      end
    end

    def write_property_tree(obj)
      case obj
      in true | false => bool
        write_u8(1)
        write_bool(false)
        write_bool(bool)
      in Float => dbl
        write_u8(2)
        write_bool(false)
        write_double(dbl)
      in String => str
        write_u8(3)
        write_bool(false)
        write_str_property(str)
      in Array => list
        write_u8(4)
        write_bool(false)
        write_list(list)
      in Hash => dict
        write_u8(5)
        write_bool(false)
        write_dictionary(dict)
      else
        raise Nauvisian::UnknownPropertyType, obj.class
      end
    end
  end
end
