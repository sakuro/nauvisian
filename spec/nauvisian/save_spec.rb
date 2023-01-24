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

        it "raises ArgumentError" do
          expect { save }.to raise_error(ArgumentError)
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
          expect(save.mods.keys.map(&:name)).to contain_exactly(*%w(base AutoDeconstruct even-distribution))
          expect(save.mods).to eq(
            Nauvisian::Mod[name: "base"] => Nauvisian::Version24["1.1.74"],
            Nauvisian::Mod[name: "AutoDeconstruct"] => Nauvisian::Version24["0.3.5"],
            Nauvisian::Mod[name: "even-distribution"] => Nauvisian::Version24["1.0.10"]
          )
        end
      end
    end
  end
end
