# frozen_string_literal: true

require "stringio"

require "zip"

RSpec.describe Nauvisian::Save do
  describe ".load" do
    context "with non existing file" do
      it "raises Zip::Error" do
        expect { Nauvisian::Save.load("non-existing.zip") }.to raise_error(Zip::Error)
      end
    end

    context "with non zip file" do
      it "raises Zip::Error" do
        expect { Nauvisian::Save.load("spec/fixtures/save/non-zip.zip") }.to raise_error(Zip::Error)
      end
    end

    context "with zip without level-init.dat nor level.dat0 in it" do
      it "raises Errno::ENOENT" do
        expect { Nauvisian::Save.load("spec/fixtures/save/without-level.zip") }.to raise_error(Errno::ENOENT)
      end
    end

    context "with zip file" do
      let(:save) { Nauvisian::Save.load(zip_path) }

      context "with wrong version" do
        let(:zip_path) { "spec/fixtures/save/wrong-version.zip" }

        it "raises Nauvisian::UnsupportedVersionr" do
          expect { save }.to raise_error(Nauvisian::UnsupportedVersion)
        end
      end

      context "with no mods except base" do
        let(:zip_path) { "spec/fixtures/save/without-mods.zip" }

        it "has version" do
          expect(save.version).to eq(Nauvisian::Version64[1, 1, 74, 1])
        end

        it "includes only the base MOD" do
          expect(save.mods).to eq(Nauvisian::Mod[name: "base"] => Nauvisian::Version24["1.1.74"])
        end
      end

      context "with MODs other than base" do
        let(:zip_path) { "spec/fixtures/save/with-some-mods.zip" }

        it "has version" do
          expect(save.version).to eq(Nauvisian::Version64[1, 1, 74, 1])
        end

        it "includes base and other MODs in the save" do
          expect(save.mods.keys.map(&:name)).to match_array(%w(base AutoDeconstruct BottleneckLite even-distribution flib))
          expect(save.mods).to eq(
            Nauvisian::Mod[name: "base"] => Nauvisian::Version24["1.1.74"],
            Nauvisian::Mod[name: "AutoDeconstruct"] => Nauvisian::Version24["0.3.5"],
            Nauvisian::Mod[name: "BottleneckLite"] => Nauvisian::Version24["1.2.4"],
            Nauvisian::Mod[name: "even-distribution"] => Nauvisian::Version24["1.0.10"],
            Nauvisian::Mod[name: "flib"] => Nauvisian::Version24["0.12.4"]
          )
        end

        it "loads startup settings" do
          expect(save.startup_settings).to eq(
            "bnl-color-disabled" => {"value" => "red"},
            "bnl-color-full_output" => {"value" => "yellow"},
            "bnl-color-idle" => {"value" => "red"},
            "bnl-color-insufficient_input" => {"value" => "red"},
            "bnl-color-low_power" => {"value" => "yellow"},
            "bnl-color-no_minable_resources" => {"value" => "red"},
            "bnl-color-no_power" => {"value" => "red"},
            "bnl-color-working" => {"value" => "green"},
            "bnl-enable" => {"value" => true},
            "bnl-glow" => {"value" => true},
            "bnl-include-mining-drills" => {"value" => true},
            "bnl-indicator-size" => {"value" => "small"}
          )
        end
      end
    end
  end
end
