# frozen_string_literal: true

require "json"
require "open-uri"

require "rack/utils"

require "nauvisian/error"

module Nauvisian
  # Mod Portal API
  # https://wiki.factorio.com/Mod_portal_API
  class API
    class Error < Nauvisian::Error; end

    MOD_PORTAL_ENDPOINT_URI = URI("https://mods.factorio.com").freeze
    private_constant :MOD_PORTAL_ENDPOINT_URI

    def initialize
      @cache = Nauvisian::Cache::FileSystem.new(name: "api")
    end

    def detail(mod)
      with_error_handling(mod) do
        path = "/api/mods/#{mod.name}/full"
        raw_data = get(path)
        data = raw_data.slice(:downloads_count, :name, :owner, :summary, :title, :category, :description)
        Nauvisian::Mod::Detail[created_at: Time.parse(raw_data[:created_at]), **data]
      end
    end

    def releases(mod)
      with_error_handling(mod) do
        path = "/api/mods/#{mod.name}"
        raw_data = get(path)
        parse_releases(raw_data[:releases], mod:)
      end
    end

    private def with_error_handling(mod)
      yield
    rescue OpenURI::HTTPError => e
      case e.io.status
      in ["404", _]
        raise Nauvisian::ModNotFound, mod
      else
        raise Nauvisian::API::Error, e.io.status
      end
    end

    private def parse_releases(raw_releases, mod:)
      raw_releases.map do |raw_release|
        data = raw_release.slice(:file_name, :sha1)
        data[:download_url] = MOD_PORTAL_ENDPOINT_URI + raw_release[:download_url]
        data[:version] = Nauvisian::Version24[raw_release[:version]]
        data[:released_at] = Time.parse(raw_release[:released_at])
        Nauvisian::Mod::Release[mod:, **data]
      end
    end

    private def get(path, **params)
      request_url = MOD_PORTAL_ENDPOINT_URI + path
      request_url.query = Rack::Utils.build_nested_query(params)
      data = @cache.fetch(request_url) { request_url.read }
      JSON.parse(data, symbolize_names: true)
    end
  end
end
