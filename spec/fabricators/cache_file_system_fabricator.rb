# frozen_string_literal: true

Fabricator(:cache_file_system, from: "Nauvisian::Cache::FileSystem") do
  transient :name, :ttl
  name { Faker::Lorem.word.downcase }
  ttl { rand(5..100) * 60 } # 5..100 minutes in seconds
  initialize_with do |transients|
    resolved_class.new(**transients)
  end
end
