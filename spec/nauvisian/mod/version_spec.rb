# frozen_string_literal: true

RSpec.describe Nauvisian::Mod::Version do
  describe ".[]" do
    def internal_version(version) = version.instance_eval { @version } # rubocop:disable RSpec/InstanceVariable

    context "with a string" do
      it "instantiates with dotted integer triplet" do
        version = Nauvisian::Mod::Version["1.2.3"]
        expect(internal_version(version)).to eq [1, 2, 3]
      end

      it "raises with malformed string" do
        expect { Nauvisian::Mod::Version["1.2.3."] }.to raise_error(ArgumentError)
      end
    end

    context "with numbers" do
      it "instantiates with 3 integer arguments" do
        version = Nauvisian::Mod::Version[1, 2, 3]
        expect(internal_version(version)).to eq [1, 2, 3]
      end

      it "raises with 2 or less arguments" do
        expect { Nauvisian::Mod::Version[1, 2] }.to raise_error(ArgumentError)
      end

      it "raises with 4 or more arguments" do
        expect { Nauvisian::Mod::Version[1, 2, 3, 4] }.to raise_error(ArgumentError)
      end

      it "raises with negative argument" do
        expect { Nauvisian::Mod::Version[1, 2, -3] }.to raise_error(ArgumentError)
      end

      it "raises with argument greater than 255" do
        expect { Nauvisian::Mod::Version[1, 2, 256] }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    it "returns dotted triplet" do
      expect(Nauvisian::Mod::Version[1, 2, 3].to_s).to eq("1.2.3")
    end
  end

  describe "#<=>" do
    it "can be compared" do
      expect(Nauvisian::Mod::Version[1, 2, 3] > Nauvisian::Mod::Version[1, 2, 0]).to be(true)
      expect(Nauvisian::Mod::Version[1, 2, 3] > Nauvisian::Mod::Version[1, 1, 3]).to be(true)
      expect(Nauvisian::Mod::Version[1, 2, 3] > Nauvisian::Mod::Version[0, 2, 3]).to be(true)
      expect(Nauvisian::Mod::Version[1, 2, 3] == Nauvisian::Mod::Version[1, 2, 3]).to be(true) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      expect(Nauvisian::Mod::Version[1, 2, 3] < Nauvisian::Mod::Version[1, 2, 4]).to be(true)
      expect(Nauvisian::Mod::Version[1, 2, 3] < Nauvisian::Mod::Version[1, 3, 3]).to be(true)
      expect(Nauvisian::Mod::Version[1, 2, 3] < Nauvisian::Mod::Version[2, 2, 3]).to be(true)
    end
  end
end
