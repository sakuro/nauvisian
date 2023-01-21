# frozen_string_literal: true

RSpec.describe Nauvisian::Mod do
  describe "#base?" do
    context "when it is the base mod" do
      let(:mod) { Nauvisian::Mod[name: "base"] }

      it "is truthy" do
        expect(mod.base?).to be_truthy
      end
    end

    context "when it is not the base mod" do
      let(:mod) { Nauvisian::Mod[name: "Krastorio2"] }

      it "is falsy" do
        expect(mod.base?).to be_falsy
      end
    end
  end
end
