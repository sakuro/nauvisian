# frozen_string_literal: true

RSpec.describe Nauvisian::ModSettings do
  let(:mod_settings_path) { Pathname("spec/fixtures/settings/mod-settings_1.1.dat") }
  let(:parsed_result) { JSON.load_file("spec/fixtures/settings/mod-settings_1.1.json") }

  describe ".load" do
    let(:settings) { Nauvisian::ModSettings.load(mod_settings_path) }

    context "with valid settings file" do
      it "parses the binary" do
        expect(settings["startup"]).to eq(parsed_result["startup"])
        expect(settings["runtime-global"]).to eq(parsed_result["runtime-global"])
        expect(settings["runtime-per-user"]).to eq(parsed_result["runtime-per-user"])
      end
    end
  end

  describe "#save" do
    let(:original_settings) { Nauvisian::ModSettings.load(mod_settings_path) }

    it "saves serialized binary" do
      Tempfile.open(%w[mod-settings- .dat], mode: 0644) do |file|
        original_settings.save(file.path)
        expect(File.binread(file.path)).to eq(File.binread(mod_settings_path))
      end
    end
  end
end
