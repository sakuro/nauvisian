# frozen_string_literal: true

require "rack/utils"

RSpec.describe Nauvisian::Downloader do
  describe "#download" do
    let(:mod) { Fabricate(:mod) }
    let(:release) { Fabricate(:release, mod:) }
    let(:credential) { Fabricate(:credential) }
    let(:downloader) { Nauvisian::Downloader.new(credential) }
    let(:url) { release.download_url.dup.tap {|url| url.query = Rack::Utils.build_nested_query(credential.to_h) } }
    let(:actual_download_url) {
      secure = "#{Faker::Alphanumeric.alphanumeric(number: 22)},#{Time.now.to_i + 3600}"
      random_hexadecimal = Faker::Number.hexadecimal(digits: 40)
      path = "/download/#{random_hexadecimal}/#{release.file_name}?secure=#{secure}"
      URI(Faker::Internet.url(scheme: "https", host: "dl-mod.factorio.com", path:))
    }
    let(:tmpdir) { Dir.mktmpdir }
    let(:output_path) { File.join(tmpdir, release.file_name) }

    after do
      FileUtils.remove_entry_secure(tmpdir) if File.directory?(tmpdir)
    end

    context "when credential is not valid" do
      before do
        login_url = url + "/login?next=#{CGI.escape(release.download_url.to_s)}"
        stub_request(:get, url.to_s).and_return(
          headers: { location: login_url.request_uri },
          status: 302
        )
        stub_request(:get, login_url.to_s).and_return(
          headers: { content_type: "text/html; charset=utf-8" },
          status: 200
        )
      end

      it "raises Nauvisian::AuthError" do
        expect { downloader.download(release, output_path) }.to raise_error(Nauvisian::AuthError)
      end
    end

    context "when given release of mod exists" do
      let(:zip_data) { "" }

      before do
        stub_request(:get, url.to_s).and_return(
          status: 302,
          headers: { location: actual_download_url.to_s }
        )
        stub_request(:get, actual_download_url.to_s).and_return(
          status: 200,
          headers: { "content-type": "application/octet-stream" },
          body: zip_data
        )

        allow(Digest::SHA1).to receive(:file).with(output_path).and_return(release.sha1)
      end

      it "downloads release" do
        expect { downloader.download(release, output_path) }.to change { File.exist?(output_path) }.from(false).to(true)
      end

      context "downloaded release is broken" do
        let(:invalid_sha1) { Faker::Number.hexadecimal(digits: 40) }

        before do
          allow(Digest::SHA1).to receive(:file).with(output_path).and_return(invalid_sha1)
        end

        it "raises Nauvisian::DigestError" do
          expect { downloader.download(release, output_path) }.to raise_error(Nauvisian::DigestError)
        end
      end
    end

    context "when given release of mod does not exist" do
      before do
        stub_request(:get, url.to_s).and_return(
          status: 404
        )
      end

      it "raises Nauvisian::NotFound" do
        expect { downloader.download(release, output_path) }.to raise_error(Nauvisian::NotFound)
      end
    end
  end
end
