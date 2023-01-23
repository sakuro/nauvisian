# frozen_string_literal: true

RSpec.describe Nauvisian::Mod::Detail do
  describe "#url" do
    let(:detail) { Fabricate(:detail) }

    it "returns URL" do
      expect(detail.url).to eq(URI("https://mods.factorio.com/mod/#{detail.name}"))
    end
  end
end
