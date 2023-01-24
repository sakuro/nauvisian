# frozen_string_literal: true

RSpec.describe Nauvisian::ModSettings do
  let(:settings) { Nauvisian::ModSettings.load(mod_settings_path) }

  context "with valid settings file" do
    let(:mod_settings_path) { Pathname("spec/fixtures/settings/mod-settings_1.1.dat") }
    let(:parsed_result) { JSON.load_file("spec/fixtures/settings/mod-settings_1.1.json") }

    it "parses the binary" do
      expect(settings["startup"]).to eq(parsed_result["startup"])
      expect(settings["runtime-global"]).to eq(parsed_result["runtime-global"])
      expect(settings["runtime-per-user"]).to eq(parsed_result["runtime-per-user"])
    end
  end
end
