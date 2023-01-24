# frozen_string_literal: true

Fabricator(:release, from: "Nauvisian::Mod::Release") do
  transient :mod, :download_url, :file_name, :released_at, :version, :sha1
  mod { Fabricate(:mod) }
  download_url {|attrs| URI("https://mods.factorio.com") + "/download/#{attrs[:mod].name}/#{Faker::Number.hexadecimal(digits: 24)}" }
  file_name {|attrs| "#{attrs[:mod].name}_#{attrs[:version]}.zip" }
  released_at { Faker::Time.backward }
  version { Nauvisian::Version24[Faker::App.semantic_version] }

  initialize_with do |transients|
    resolved_class[**transients]
  end
end
