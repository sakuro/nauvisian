# frozen_string_literal: true

RSpec.describe Nauvisian::API do
  let(:api) { Nauvisian::API.new }

  describe "#detail" do
    let(:mod) { Nauvisian::Mod[name: "test-mod"] }

    context "when given mod does not exist" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/test-mod").to_return(
          body: JSON.generate(message: "Mod not found"),
          status: 404
        )
      end

      it "raisess ModNotFound" do
        expect { api.detail(mod) }.to raise_error(Nauvisian::API::ModNotFound)
      end
    end

    context "when given mod exists" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/test-mod").to_return(
          body: JSON.generate(
            category: "general",
            downloads_count: 123,
            name: "test-mod",
            owner: "not-a-user",
            releases: [],
            summary: "A test MOD for RSpec",
            title: "A test MOD"
          ),
          status: 200
        )
      end

      it "returns Nauvisian::Mod::Detail" do
        expect(api.detail(mod)).to eq(Nauvisian::Mod::Detail[
          category: "general",
          downloads_count: 123,
          name: "test-mod",
          owner: "not-a-user",
          summary: "A test MOD for RSpec",
          title: "A test MOD"
        ])
      end
    end
  end

  describe "#releases" do
    let(:mod) { Nauvisian::Mod[name: "test-mod"] }

    context "when given mod does not exist" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/test-mod").to_return(
          body: JSON.generate(message: "Mod not found"),
          status: 404
        )
      end

      it "raisess ModNotFound" do
        expect { api.releases(mod) }.to raise_error(Nauvisian::API::ModNotFound)
      end
    end

    context "when given mod exists" do
      before do
        stub_request(:get, Nauvisian::API::MOD_PORTAL_ENDPOINT_URI + "/api/mods/test-mod").to_return(
          body: JSON.generate(
            releases: [
              {
                download_url: "/download/test-mod/0123456789abcdef01234567",
                file_name: "test-mod_0.0.1.zip",
                released_at: "2023-01-01T00:00:00.000000Z",
                sha1: "0123456789abcdef0123456789abcdef01234567",
                version: "0.0.1"
              },
              {
                download_url: "/download/test-mod/89abcdef0123456789abcdef",
                file_name: "test-mod_0.0.2.zip",
                released_at: "2023-01-02T01:02:03.000000Z",
                sha1: "89abcdef0123456789abcdef0123456789abcdef",
                version: "0.0.2"
              }
            ]
          ),
          status: 200
        )
      end

      it "returns array of Nauvisian::Mod::Release" do
        expect(api.releases(mod)).to contain_exactly(
          Nauvisian::Mod::Release[
            download_url:  URI("https://mods.factorio.com/download/test-mod/0123456789abcdef01234567"),
            file_name: "test-mod_0.0.1.zip",
            released_at: Time.parse("2023-01-01T00:00:00.000000Z"),
            sha1: "0123456789abcdef0123456789abcdef01234567",
            version: Nauvisian::Mod::Version[0, 0, 1]
          ],
          Nauvisian::Mod::Release[
            download_url:  URI("https://mods.factorio.com/download/test-mod/89abcdef0123456789abcdef"),
            file_name: "test-mod_0.0.2.zip",
            released_at: Time.parse("2023-01-02T01:02:03.000000Z"),
            sha1: "89abcdef0123456789abcdef0123456789abcdef",
            version: Nauvisian::Mod::Version[0, 0, 2]
          ]
        )
      end
    end
  end
end
