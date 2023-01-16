# frozen_string_literal: true

require "stringio"

RSpec.describe Nauvisian::Save::Deserializer do
  let(:deserializer) { Nauvisian::Save::Deserializer.new(stream) }
  let(:stream) { StringIO.new(binary_data) }

  describe ".new" do
    context "with object without #read" do
      it "raises ArgumentError if the argument does not respond to #read" do
        expect { Nauvisian::Save::Deserializer.new(%w(x y z)) }.to raise_error(ArgumentError)
      end
    end

    it "instantiates with an input stream" do
      expect(Nauvisian::Save::Deserializer.new(StringIO.new("\x00\x01\x00\x02"))).to be_an_instance_of(Nauvisian::Save::Deserializer)
    end
  end

  describe "#read_bytes" do
    let(:binary_data) { "\x00\x01\x02\x03\x04\x05\x06\x07" }

    it "returns the bytes read" do
      expect(deserializer.read_bytes(5)).to eq("\x00\x01\x02\x03\x04")
    end

    context "with zero length" do
      it "returns an empty string" do
        expect(deserializer.read_bytes(0)).to eq("")
      end
    end

    context "with negative length" do
      it "raises ArgumentError" do
        expect { deserializer.read_bytes(-1) }.to raise_error(ArgumentError)
      end
    end

    context "when reaches EOF" do
      it "raises EOFError" do
        expect { deserializer.read_bytes(10) }.to raise_error(EOFError)
      end
    end

    context "with nil length" do
      it "returns bytes read until EOF" do
        expect(deserializer.read_bytes(nil)).to eq("\x00\x01\x02\x03\x04\x05\x06\x07")
      end
    end
  end

  describe "#read_u8" do
    let(:binary_data) { "\xaa" }

    it "returns byte read" do
      expect(deserializer.read_u8).to eq(0xAA)
    end

    context "with not enough bytes left" do
      let(:binary_data) { "" }

      it "raises EOFerror" do
        expect { deserializer.read_u8 }.to raise_error(EOFError)
      end
    end
  end

  describe "#read_u16" do
    let(:binary_data) { "\xaa\xbb" }

    it "returns byte read" do
      expect(deserializer.read_u16).to eq(0xBBAA)
    end

    context "with not enough bytes left" do
      let(:binary_data) { "\xaa" }

      it "raises EOFerror" do
        expect { deserializer.read_u16 }.to raise_error(EOFError)
      end
    end
  end

  describe "#read_u32" do
    let(:binary_data) { "\xaa\xbb\xcc\xdd" }

    it "returns byte read" do
      expect(deserializer.read_u32).to eq(0xDDCCBBAA)
    end

    context "with not enough bytes left" do
      let(:binary_data) { "\xaa\xbb\xcc" }

      it "raises EOFerror" do
        expect { deserializer.read_u32 }.to raise_error(EOFError)
      end
    end
  end

  describe "#read_optim_u16" do
    context "when leading byte is not 0xFF" do
      let(:binary_data) { "\x99\xaa\xbb" }

      it "returns the leading byte" do
        expect(deserializer.read_optim_u16).to eq(0x99)
      end
    end

    context "when leading byte is 0xFF" do
      let(:binary_data) { "\xff\xaa\xbb" }

      it "returns 2 bytes after the leading length" do
        expect(deserializer.read_optim_u16).to eq(0xBBAA)
      end

      context "with not enough bytes left" do
        let(:binary_data) { "\xff\xaa" }

        it "raises EOFError" do
          expect { deserializer.read_optim_u16 }.to raise_error(EOFError)
        end
      end
    end
  end

  describe "#read_optim_u32" do
    context "when leading byte is not 0xFF" do
      let(:binary_data) { "\x99\xaa\xbb\xcc\xdd" }

      it "returns the leading byte" do
        expect(deserializer.read_optim_u32).to eq(0x99)
      end
    end

    context "when leading byte is 0xFF" do
      let(:binary_data) { "\xff\xaa\xbb\xcc\xdd" }

      it "returns 4 bytes after the leading length" do
        expect(deserializer.read_optim_u32).to eq(0xDDCCBBAA)
      end

      context "with not enough bytes left" do
        let(:binary_data) { "\xff\xaa\xbb\xcc" }

        it "raises EOFError" do
          expect { deserializer.read_optim_u32 }.to raise_error(EOFError)
        end
      end
    end
  end
end
