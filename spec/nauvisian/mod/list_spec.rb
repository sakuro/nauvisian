# frozen_string_literal: true

RSpec.describe Nauvisian::Mod::List do
  let(:base_mod) { Nauvisian::Mod[name: "base"] }
  let(:enabled_mod) { Nauvisian::Mod[name: "enabled-mod"] }
  let(:disabled_mod) { Nauvisian::Mod[name: "disabled-mod"] }
  let(:non_listed_mod) { Nauvisian::Mod[name: "non-listed-mod"] }

  let(:list) { Nauvisian::Mod::List.load("spec/fixtures/list/list.json") }

  # describe ".load"
  # describe "#save"
  # def each

  describe "#add" do
    it "adds non-listed MOD" do
      expect { list.add(non_listed_mod) }.to change { list.exist?(non_listed_mod) }.from(false).to(true)
    end

    it "adds MOD as enabled without explicit flag" do
      list.add(non_listed_mod)
      expect(list).to be_enabled(non_listed_mod)
    end

    it "adds MOD as enabled with explicit true flag" do
      list.add(non_listed_mod, enabled: true)
      expect(list).to be_enabled(non_listed_mod)
    end

    it "adds MOD as disabled with explicit false flag" do
      list.add(non_listed_mod, enabled: false)
      expect(list).not_to be_enabled(non_listed_mod)
    end

    it "enables already listed disabled MOD withoput explicit flag" do
      expect { list.add(disabled_mod) }.to change { list.enabled?(disabled_mod) }.from(false).to(true)
    end

    it "enables already listed disabled MOD with explicit true flag" do
      expect { list.add(disabled_mod, enabled: true) }.to change { list.enabled?(disabled_mod) }.from(false).to(true)
    end

    it "disables already listed enabled MOD with explicit false flag" do
      expect { list.add(enabled_mod, enabled: false) }.to change { list.enabled?(enabled_mod) }.from(true).to(false)
    end

    it "can't add base MOD as enabled: false" do
      expect { list.add(base_mod, enabled: false) }.to raise_error(ArgumentError)
    end
  end

  describe "#remove" do
    it "removes listed MOD" do
      expect { list.remove(enabled_mod) }.to change { list.exist?(enabled_mod) }.from(true).to(false)
    end

    it "does nothing on removing non-listed MOD" do
      expect { list.remove(non_listed_mod) }.not_to raise_error
    end

    it "raises ArgumentError on removing base MOD" do
      expect { list.remove(base_mod) }.to raise_error(ArgumentError)
    end
  end

  describe "#exist?" do
    it "is truthy for listed MOD" do
      expect(list).to exist(base_mod)
    end

    it "is falsy for non-listed MOD" do
      expect(list).not_to exist(non_listed_mod)
    end
  end

  describe "#enable" do
    it "can enable listed MOD" do
      expect { list.enable(disabled_mod) }.to change { list.enabled?(disabled_mod) }.from(false).to(true)
    end

    it "does nothing to already enabled MOD" do
      expect { list.enable(enabled_mod) }.not_to change { list.enabled?(enabled_mod) }.from(true)
    end

    it "raises KeyError on enabling non-listed MOD" do
      expect { list.enable(non_listed_mod) }.to raise_error(KeyError)
    end
  end

  describe "#disable" do
    it "can disable listed MOD" do
      expect { list.disable(enabled_mod) }.to change { list.enabled?(enabled_mod) }.from(true).to(false)
    end

    it "does nothing to already disabled MOD" do
      expect { list.disable(disabled_mod) }.not_to change { list.enabled?(disabled_mod) }.from(false)
    end

    it "raises KeyError on disabling non-listed MOD" do
      expect { list.disable(non_listed_mod) }.to raise_error(KeyError)
    end

    it "raises ArgumentError on disabling base MOD" do
      expect { list.disable(base_mod) }.to raise_error(ArgumentError)
    end
  end

  describe "#enabled?" do
    it "is truthy for enabled MOD" do
      expect(list).to be_enabled(enabled_mod)
    end

    it "is falsy for disabled MOD" do
      expect(list).not_to be_enabled(disabled_mod)
    end

    it "raises KeyError for non-listed MOD" do
      expect { list.enabled?(non_listed_mod) }.to raise_error(KeyError)
    end
  end
end
