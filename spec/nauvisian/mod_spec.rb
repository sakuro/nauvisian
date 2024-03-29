# frozen_string_literal: true

RSpec.describe Nauvisian::Mod do
  describe "#base?" do
    context "when it is the base mod" do
      let(:mod) { Fabricate(:mod, name: "base") }

      it "is truthy" do
        expect(mod).to be_base
      end
    end

    context "when it is not the base mod" do
      let(:mod) { Fabricate(:mod) }

      it "is falsy" do
        expect(mod).not_to be_base
      end
    end
  end

  describe "#<=>" do
    it "can be compared by case insensitive name" do
      expect(Nauvisian::Mod[name: "BAR"] < Nauvisian::Mod[name: "foo"]).to be_truthy
      expect(Nauvisian::Mod[name: "foo"] == Nauvisian::Mod[name: "Foo"]).to be_truthy
      expect(Nauvisian::Mod[name: "foo"] != Nauvisian::Mod[name: "bar"]).to be_truthy
      expect(Nauvisian::Mod[name: "foo"] > Nauvisian::Mod[name: "Bar"]).to be_truthy
    end

    context "when self is base" do
      it "is always smaller then non-base MOD" do
        expect(Nauvisian::Mod[name: "base"] < Nauvisian::Mod[name: "a"]).to be_truthy
      end
    end

    context "when self is non-base" do
      it "is always bigger than base MOD" do
        expect(Nauvisian::Mod[name: "a"] > Nauvisian::Mod[name: "base"]).to be_truthy
      end
    end
  end
end
