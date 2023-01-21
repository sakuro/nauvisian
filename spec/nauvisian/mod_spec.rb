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
end
