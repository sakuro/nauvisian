# frozen_string_literal: true

require "rack/utils"

require "digest/sha1"

module Nauvisian
  class Downloader
    MAX_REDIRECTIONS = 10
    private_constant :MAX_REDIRECTIONS

    def initialize(credential)
      @credential = credential
    end

    def download(release, output_path)
      url = release.download_url.dup
      url.query = Rack::Utils.build_nested_query(@credential.to_h)
      res = get(url)
      File.binwrite(output_path, res.body)
      raise DigestError, "Digest mismatch" unless Digest::SHA1.file(output_path) == release.sha1
    end

    private def get(url, visited=[])
      raise Nauvisian::TooManyRedirections if visited.size > MAX_REDIRECTIONS

      req = Net::HTTP::Get.new(url.request_uri)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      res = https.start { https.request(req) }

      case res
      when Net::HTTPRedirection
        location = URI(res["location"])
        raise Nauvisian::AuthError if location.path == "/login"

        get(location, visited + [url])
      when Net::HTTPOK
        res
      when Net::HTTPNotFound
        raise Nauvisian::NotFound, res.message
      else
        raise Nauvisian::Error, res.message
      end
    end
  end
end
