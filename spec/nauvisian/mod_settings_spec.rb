# frozen_string_literal: true

RSpec.describe Nauvisian::ModSettings do
  let(:mod_settings_path) { Pathname("spec/fixtures/settings/mod-settings_1.1.dat") }
  let(:parsed_result) { JSON.load_file("spec/fixtures/settings/mod-settings_1.1.json") }
  let(:settings) { Nauvisian::ModSettings.load(mod_settings_path) }

  describe ".load" do
    context "with valid settings file" do
      it "parses the binary" do
        expect(settings["startup"]).to eq(parsed_result["startup"])
        expect(settings["runtime-global"]).to eq(parsed_result["runtime-global"])
        expect(settings["runtime-per-user"]).to eq(parsed_result["runtime-per-user"])
      end
    end
  end

  describe "#save" do
    it "saves serialized binary" do
      Tempfile.open(%w[mod-settings- .dat], mode: 0644) do |file|
        settings.save(file.path)
        expect(File.binread(file.path)).to eq(File.binread(mod_settings_path))
      end
    end
  end

  describe "#[]" do
    it "returns toplevel hash" do
      expect(settings["startup"]).to eq(parsed_result["startup"])
    end
  end

  describe "#[]=" do
    it "replaces toplevel hash" do
      expect { settings["startup"] = {"angels-cab-energy-transfer-rate-mk1" => {"value" => 0}} }.to change {
        settings["startup"]["angels-cab-energy-transfer-rate-mk1"]["value"]
      }.from(500_000).to(0)
    end
  end

  describe "#to_json" do
    it "includes version" do
      expect(JSON.parse(settings.to_json)).to include("version" => "1.1.37-0")
    end
  end
end
