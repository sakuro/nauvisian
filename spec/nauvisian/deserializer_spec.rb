# frozen_string_literal: true

require "stringio"

RSpec.describe Nauvisian::Deserializer do
  let(:deserializer) { Nauvisian::Deserializer.new(stream) }
  let(:stream) { StringIO.new(binary_data) }

  describe ".new" do
    context "with object without #read" do
      it "raises ArgumentError if the argument does not respond to #read" do
        expect { Nauvisian::Deserializer.new(%w(x y z)) }.to raise_error(ArgumentError)
      end
    end

    it "instantiates with an input stream" do
      expect(Nauvisian::Deserializer.new(StringIO.new("\x00\x01\x00\x02"))).to be_an_instance_of(Nauvisian::Deserializer)
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
      it "returns ArgumentError" do
        expect { deserializer.read_bytes(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#read_u8" do
    let(:binary_data) { "\xaa" }

    it "returns byte read" do
      expect(deserializer.read_u8).to eq(0xAA)
    end

    context "with not enough bytes left" do # rubocop:disable RSpec/RepeatedExampleGroupBody
      let(:binary_data) { "" }

      it "raises EOFerror" do
        expect { deserializer.read_u8 }.to raise_error(EOFError)
      end
    end

    context "at EOF" do # rubocop:disable RSpec/RepeatedExampleGroupBody
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

    context "at EOF" do
      let(:binary_data) { "" }

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

    context "at EOF" do
      let(:binary_data) { "" }

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

  describe "#read_bool" do
    context "reading 0x00" do
      let(:binary_data) { "\x00" }

      it "reads 0x00 as false" do
        expect(deserializer.read_bool).to be(false)
      end
    end

    context "reading non-0x00" do
      let(:binary_data) { "\x11" }

      it "reads non-0x00 as true" do
        expect(deserializer.read_bool).to be(true)
      end
    end
  end

  describe "#read_str" do
    context "when leading byte is 0xFF" do
      # ,\x01\x00\x00 (\x2c\x01\x00\x00) is 300
      let(:binary_data) { "\xff,\x01\x00\x00#{"x" * 300}" }

      it "reads string of length designated in u32 after the leading byte" do
        expect(deserializer.read_str).to eq("x" * 300)
      end
    end

    context "when leading byte is not 0xFF" do
      let(:binary_data) { "\x0chello, world" }

      it "reads string of length designated by the leading byte itself" do
        expect(deserializer.read_str).to eq("hello, world")
      end
    end
  end

  describe "#read_str_property" do
    context "when no string flag is set" do
      let(:binary_data) { "\x01" }

      it "reads an empty string" do
        expect(deserializer.read_str_property).to eq("")
      end
    end

    context "when no string flag is unset" do
      let(:binary_data) { "\x00\x03abc" }

      it "reads string" do
        expect(deserializer.read_str_property).to eq("abc")
      end
    end
  end

  describe "#read_double" do
    let(:binary_data) { "\x00\x00\x00\x00\xe0\xff\xff\x3f" }

    it "returns byte read" do
      # 1.999969482421875 is precisely represented in IEEE754 without error
      expect(deserializer.read_double).to be_within(0).of(1.999969482421875)
    end

    context "with not enough bytes left" do
      let(:binary_data) { "\x00\x00\x00\x00\xe0\xff\xff" }

      it "raises EOFerror" do
        expect { deserializer.read_double }.to raise_error(EOFError)
      end
    end
  end

  xdescribe "#read_list"
  xdescribe "#read_dictionary"
  xdescribe "#read_property_tree"
end
