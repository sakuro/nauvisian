# frozen_string_literal: true

Fabricator(:cache_redis, from: "Nauvisian::Cache::Redis") do
  transient :name, :ttl, :lock_ttl
  name { Faker::Lorem.word.downcase }
  ttl { rand(5..100) * 60 } # 5..100 minutes in seconds
  lock_ttl { rand(5..10) }
  initialize_with do |transients|
    resolved_class.new(**transients)
  end
end
