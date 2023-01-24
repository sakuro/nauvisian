# frozen_string_literal: true

RSpec.describe Nauvisian::Platform do
  describe ".platform" do
    before do
      allow(RbConfig::CONFIG).to receive(:[]).and_call_original
    end

    context "when on Linux" do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with("host_os").and_return("linux")
      end

      it "is Linux" do
        expect(Nauvisian::Platform.platform).to be_an_instance_of(Nauvisian::Platform::Linux)
      end
    end

    context "when on macOS" do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with("host_os").and_return("darwin")
      end

      it "is MacOS" do
        expect(Nauvisian::Platform.platform).to be_an_instance_of(Nauvisian::Platform::MacOS)
      end
    end

    context "when on Windows" do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with("host_os").and_return("mswin")
      end

      it "is Windows" do
        expect(Nauvisian::Platform.platform).to be_an_instance_of(Nauvisian::Platform::Windows)
      end
    end
  end
end
