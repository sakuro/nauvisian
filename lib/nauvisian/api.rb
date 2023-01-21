# frozen_string_literal: true

require_relative "mod"

require "rack/utils"

require "json"
require "net/https"

module Nauvisian
  # Mod Portal API
  # https://wiki.factorio.com/Mod_portal_API
  class API
    MOD_PORTAL_ENDPOINT_URI = URI("https://mods.factorio.com").freeze
    public_constant :MOD_PORTAL_ENDPOINT_URI

    def detail(mod)
      path = "/api/mods/#{mod.name}"
      raw_data = get(path)
      data = raw_data.slice(:downloads_count, :name, :owner, :summary, :title, :category)
      Nauvisian::Mod::Detail[**data]
    end

    def releases(mod)
      path = "/api/mods/#{mod.name}"
      raw_data = get(path)
      parse_releases(raw_data[:releases], mod:)
    end

    private def parse_releases(raw_releases, mod:)
      raw_releases.map do |raw_release|
        data = raw_release.slice(:file_name, :sha1)
        data[:download_url] = URI("https://mods.factorio.com") + raw_release[:download_url]
        data[:version] = Mod::Version[raw_release[:version]]
        data[:released_at] = Time.parse(raw_release[:released_at])
        Nauvisian::Mod::Release[mod:, **data]
      end
    end

    private def get(path, **params)
      query = Rack::Utils.build_nested_query(params)
      req = Net::HTTP::Get.new(query.empty? ? path : path + "?" + query)
      res = request(req)
      case res
      when Net::HTTPOK
        JSON.parse(res.body, symbolize_names: true)
      when Net::HTTPNotFound
        raise Nauvisian::NotFound, JSON.parse(res.body, symbolize_names: true)[:message]
      else
        raise Nauvisian::Error
      end
    end

    private def request(req)
      https = Net::HTTP.new(MOD_PORTAL_ENDPOINT_URI.host, MOD_PORTAL_ENDPOINT_URI.port)
      https.use_ssl = true
      https.start do
        https.request(req)
      end
    end
  end
end
