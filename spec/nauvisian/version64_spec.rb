# frozen_string_literal: true

RSpec.describe Nauvisian::Version64 do
  describe ".[]" do
    def internal_version(version) = version.instance_eval { @version } # rubocop:disable RSpec/InstanceVariable

    context "with a string" do
      it "instantiates with dotted integer triplet followed by a dash and an integer" do
        version = Nauvisian::Version64["1.2.3-4"]
        expect(internal_version(version)).to eq [1, 2, 3, 4]
      end

      it "instantiates with dotted integer triplet without dash part" do
        version = Nauvisian::Version64["1.2.3"]
        expect(internal_version(version)).to eq [1, 2, 3, 0]
      end

      it "raises with malformed string" do
        expect { Nauvisian::Version64["1.2.3."] }.to raise_error(ArgumentError)
      end
    end

    context "with numbers" do
      it "instantiates with 4 integer arguments" do
        version = Nauvisian::Version64[1, 2, 3, 4]
        expect(internal_version(version)).to eq [1, 2, 3, 4]
      end

      it "raises with 3 or less arguments" do
        expect { Nauvisian::Version64[1, 2, 3] }.to raise_error(ArgumentError)
      end

      it "raises with 5 or more arguments" do
        expect { Nauvisian::Version64[1, 2, 3, 4, 5] }.to raise_error(ArgumentError)
      end

      it "raises with negative argument" do
        expect { Nauvisian::Version64[1, 2, 3, -4] }.to raise_error(ArgumentError)
      end

      it "raises with argument greater than 65535" do
        expect { Nauvisian::Version64[1, 2, 3, 65536] }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    it "returns dotted triplet followed by dash and an integer" do
      expect(Nauvisian::Version64[1, 2, 3, 4].to_s).to eq("1.2.3-4")
    end
  end

  describe "#<=>" do
    it "can be compared" do
      expect(Nauvisian::Version64[1, 2, 3, 4] > Nauvisian::Version64[1, 2, 3, 0]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] > Nauvisian::Version64[1, 2, 2, 3]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] > Nauvisian::Version64[1, 1, 3, 4]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] > Nauvisian::Version64[0, 2, 3, 4]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] == Nauvisian::Version64[1, 2, 3, 4]).to be(true) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      expect(Nauvisian::Version64[1, 2, 3, 4] < Nauvisian::Version64[1, 2, 3, 5]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] < Nauvisian::Version64[1, 2, 4, 4]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] < Nauvisian::Version64[1, 3, 3, 4]).to be(true)
      expect(Nauvisian::Version64[1, 2, 3, 4] < Nauvisian::Version64[2, 2, 3, 4]).to be(true)
    end
  end
end
