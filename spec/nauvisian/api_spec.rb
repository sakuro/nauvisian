# frozen_string_literal: true

RSpec.describe Nauvisian::API do
  let(:api) { Nauvisian::API.new }
  let(:mod) { Fabricate(:mod) }

  before do
    Nauvisian::API.public_constant(:MOD_PORTAL_ENDPOINT_URI)
  end

  describe "#detail" do
    context "when given mod does not exist" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}/full").to_return(
          body: JSON.generate(message: "Mod not found"),
          status: 404
        )
      end

      it "raisess ModNotFound" do
        expect { api.detail(mod) }.to raise_error(Nauvisian::ModNotFound)
      end
    end

    context "when given mod exists" do
      let(:category) { Faker::Lorem.word }
      let(:downloads_count) { Faker::Number.number(digits: 4) }
      let(:name) { mod.name }
      let(:owner) { Faker::Internet.username }
      let(:summary) { Faker::Lorem.paragraph }
      let(:title) { Faker::Lorem.sentence }
      let(:created_at) { Faker::Time.backward.utc.iso8601(6) }
      let(:description) { Faker::Lorem.paragraphs.join("\n") }

      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}/full").to_return(
          body: JSON.generate(
            category:, downloads_count:, name:, owner:, releases: [], summary:, title:, created_at:, description:
          ),
          status: 200
        )
      end

      it "returns Nauvisian::Mod::Detail" do
        expect(api.detail(mod)).to eq(Nauvisian::Mod::Detail[category:, downloads_count:, name:, owner:, summary:, title:, created_at: Time.parse(created_at), description:])
      end
    end

    context "when non-404 HTTP error occurs" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}/full").to_return(
          status: 503
        )
      end

      it "raises Nauvisian::Error" do
        expect { api.detail(mod) }.to raise_error(Nauvisian::Error)
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

      it "raises ModNotFound" do
        expect { api.releases(mod) }.to raise_error(Nauvisian::ModNotFound)
      end
    end

    context "when given mod exists" do
      let(:download_url) { "/download/#{mod.name}/#{Faker::Number.hexadecimal(digits: 24)}" }
      let(:version) { Faker::App.semantic_version }
      let(:file_name) { "#{mod.name}_#{version}.zip" }
      let(:released_at) { Faker::Time.backward.utc.iso8601(6) }
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
            version: Nauvisian::Version24[version]
          ]
        )
      end
    end

    context "when non-404 HTTP error occurs" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/#{mod.name}").to_return(
          status: 503
        )
      end

      it "raises Nauvisian::Error" do
        expect { api.releases(mod) }.to raise_error(Nauvisian::Error)
      end

      it "has OpenURI::HTTPError as its cause" do
        api.releases(mod)
      rescue Nauvisian::Error => e
        expect(e.cause).to be_an_instance_of(OpenURI::HTTPError)
      end
    end
  end
end
