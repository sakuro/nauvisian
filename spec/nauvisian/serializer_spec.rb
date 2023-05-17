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

  describe "#write_dictionary" do
    it "writes dictionary" do
      expect { serializer.write_dictionary("value" => 0.5) }.to change(stream, :string).from("".b).to("\x01\x00\x00\x00\x00\x05value\x02\x00\x00\x00\x00\x00\x00\x00\xE0\x3F".b)
    end
  end

  describe "#write_property_tree" do
    before do
      allow(serializer).to receive(:write_u8)
      allow(serializer).to receive(:write_bool).with(false)
    end

    context "when writing bool" do
      before do
        allow(serializer).to receive(:write_bool).with(true)
      end

      it "calls write_bool" do
        serializer.write_property_tree(true)

        expect(serializer).to have_received(:write_u8).with(1).ordered
        expect(serializer).to have_received(:write_bool).with(false).ordered
        expect(serializer).to have_received(:write_bool).with(true).ordered
      end
    end

    context "when writing number" do
      before do
        allow(serializer).to receive(:write_double)
      end

      it "calls write_double" do
        serializer.write_property_tree(0.5)

        expect(serializer).to have_received(:write_u8).with(2).ordered
        expect(serializer).to have_received(:write_bool).with(false).ordered
        expect(serializer).to have_received(:write_double).with(0.5).ordered
      end
    end

    context "when writing string" do
      before do
        allow(serializer).to receive(:write_str_property)
      end

      it "calls write_str_property" do
        serializer.write_property_tree("value")

        expect(serializer).to have_received(:write_u8).with(3).ordered
        expect(serializer).to have_received(:write_bool).with(false).ordered
        expect(serializer).to have_received(:write_str_property).with("value").ordered
      end
    end

    context "when writing list" do
      before do
        allow(serializer).to receive(:write_list)
      end

      it "calls write_list" do
        serializer.write_property_tree([1.0, 2.0])

        expect(serializer).to have_received(:write_u8).with(4).ordered
        expect(serializer).to have_received(:write_bool).with(false).ordered
        expect(serializer).to have_received(:write_list).with([1.0, 2.0]).ordered
      end
    end

    context "when writing dictionary" do
      before do
        allow(serializer).to receive(:write_dictionary)
      end

      it "calls write_dictionary" do
        serializer.write_property_tree("value" => 0.5)

        expect(serializer).to have_received(:write_u8).with(5).ordered
        expect(serializer).to have_received(:write_bool).with(false).ordered
        expect(serializer).to have_received(:write_dictionary).with("value" => 0.5).ordered
      end
    end

    context "when writing unknown object type" do
      it "raises Nauvisian::UnknownPropertyType" do
        expect { serializer.write_property_tree(Object.new) }.to raise_error(Nauvisian::UnknownPropertyType)
      end
    end
  end
end
