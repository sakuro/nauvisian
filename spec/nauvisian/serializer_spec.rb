# frozen_string_literal: true

require "stringio"

RSpec.describe Nauvisian::Serializer do
  let(:serializer) { Nauvisian::Serializer.new(stream) }
  let(:stream) { StringIO.new("".b) }

  describe ".new" do
    context "with object without #write" do
      it "raises ArgumentError if the argument does not respond to #write" do
        expect { Nauvisian::Serializer.new(%w(x y z)) }.to raise_error(ArgumentError)
      end
    end

    it "instantiates with an input stream" do
      expect(Nauvisian::Serializer.new(StringIO.new("".b))).to be_an_instance_of(Nauvisian::Serializer)
    end
  end

  describe "#write_bytes" do
    let(:binary_data) { "\x00\x01\x02\x03\x04\x05\x06\x07".b }

    it "writes given data" do
      expect { serializer.write_bytes(binary_data) }.to change(stream, :string).from("".b).to("\x00\x01\x02\x03\x04\x05\x06\x07".b)
    end

    context "with zero length" do
      it "writes nothing" do
        expect { serializer.write_bytes("") }.not_to change(stream, :string).from("".b)
      end
    end

    context "with nil" do
      it "raises ArgumentError" do
        expect { serializer.write_bytes(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#write_u8" do
    it "writes given value" do
      expect { serializer.write_u8(23) }.to change(stream, :string).from("".b).to("\x17".b)
    end
  end

  describe "#write_u16" do
    it "writes given value" do
      expect { serializer.write_u16(2023) }.to change(stream, :string).from("".b).to("\xE7\x07".b)
    end
  end

  describe "#write_u32" do
    it "writes given value" do
      expect { serializer.write_u32(20_230_128) }.to change(stream, :string).from("".b).to("\xF0\xAF\x34\x01".b)
    end
  end

  describe "#write_optim_u16" do
    context "when value < 256" do
      it "writes value as a byte" do
        expect { serializer.write_optim_u16(23) }.to change(stream, :string).from("".b).to("\x17".b)
      end
    end

    context "when value >= 256" do
      it "writes 0xFF and value" do
        expect { serializer.write_optim_u16(2023) }.to change(stream, :string).from("".b).to("\xFF\xE7\x07".b)
      end
    end
  end

  describe "#write_optim_u32" do
    context "when value < 256" do
      it "writes value as a byte" do
        expect { serializer.write_optim_u32(23) }.to change(stream, :string).from("".b).to("\x17".b)
      end
    end

    context "when value >= 256" do
      it "writes 0xFF and value" do
        expect { serializer.write_optim_u32(20_230_128) }.to change(stream, :string).from("".b).to("\xFF\xF0\xAF\x34\x01".b)
      end
    end
  end

  describe "#write_bool" do
    it "writes false as 0x00" do
      expect { serializer.write_bool(false) }.to change(stream, :string).from("".b).to("\x00".b)
    end

    it "writes true as 0x01" do
      expect { serializer.write_bool(true) }.to change(stream, :string).from("".b).to("\x01".b)
    end
  end

  describe "#write_str" do
    context "when writing string with length < 256" do
      it "writes length as a byte followed by string data" do
        expect { serializer.write_str("hello, world") }.to change(stream, :string).from("".b).to("\x0Chello, world".b)
      end
    end

    context "when writing string with length >= 256" do
      it "writes 0xFF, length as a u32 followed by string data" do
        expect { serializer.write_str("x" * 300) }.to change(stream, :string).from("".b).to("\xFF\x2C\x01\x00\x00#{"x" * 300}".b)
      end
    end
  end

  describe "#write_str_property" do
    context "writing empty string" do
      it "writes only no string flag as true" do
        expect { serializer.write_str_property("") }.to change(stream, :string).from("".b).to("\x01".b)
      end
    end

    context "writing non empty string" do
      it "writes no string flag asf false, length and data" do
        expect { serializer.write_str_property("hello, world") }.to change(stream, :string).from("".b).to("\x00\x0chello, world".b)
      end
    end
  end

  describe "#write_double" do
    it "writes value" do
      expect { serializer.write_double(1.999969482421875) }.to change(stream, :string).from("".b).to("\x00\x00\x00\x00\xe0\xff\xff\x3f".b)
    end
  end

  xdescribe "#write_list"
  xdescribe "#write_dictionary"
  xdescribe "#write_property_tree"
end
