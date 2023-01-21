# frozen_string_literal: true

RSpec.describe Nauvisian::API do
  let(:api) { Nauvisian::API.new }
  let(:mod) { Fabricate(:mod) }

  describe "#detail" do
    context "when given mod does not exist" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}").to_return(
          body: JSON.generate(message: "Mod not found"),
          status: 404
        )
      end

      it "raisess NotFound" do
        expect { api.detail(mod) }.to raise_error(Nauvisian::NotFound)
      end
    end

    context "when given mod exists" do
      let(:category) { Faker::Lorem.word }
      let(:downloads_count) { Faker::Number.number(digits: 4) }
      let(:name) { mod.name }
      let(:owner) { Faker::Internet.username }
      let(:summary) { Faker::Lorem.paragraph }
      let(:title) { Faker::Lorem.sentence }

      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}").to_return(
          body: JSON.generate(category:, downloads_count:, name:, owner:, releases: [], summary:, title:),
          status: 200
        )
      end

      it "returns Nauvisian::Mod::Detail" do
        expect(api.detail(mod)).to eq(Nauvisian::Mod::Detail[category:, downloads_count:, name:, owner:, summary:, title:])
      end
    end
  end

  describe "#releases" do
    context "when given mod does not exist" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}").to_return(
          body: JSON.generate(message: "Mod not found"),
          status: 404
        )
      end

      it "raisess NotFound" do
        expect { api.releases(mod) }.to raise_error(Nauvisian::NotFound)
      end
    end

    context "when given mod exists" do
      let(:download_url) { "/download/#{mod.name}/#{Faker::Number.hexadecimal(digits: 24)}" }
      let(:version) { Faker::App.semantic_version }
      let(:file_name) { "#{mod.name}_#{version}.zip" }
      let(:released_at) { Faker::Time.backward(format: :iso8601) }
      let(:sha1) { Faker::Number.hexadecimal(digits: 40) }

      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}").to_return(
          body: JSON.generate(releases: [download_url:, file_name:, released_at:, sha1:, version:]),
          status: 200
        )
      end

      it "returns array of Nauvisian::Mod::Release" do
        expect(api.releases(mod)).to contain_exactly(
          Nauvisian::Mod::Release[
            mod:,
            download_url: URI("https://mods.factorio.com") + download_url,
            file_name:,
            released_at: Time.parse(released_at),
            sha1:,
            version: Nauvisian::Mod::Version[version]
          ]
        )
      end
    end
  end
end
