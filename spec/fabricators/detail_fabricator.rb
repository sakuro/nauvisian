# frozen_string_literal: true

Fabricator(:detail, from: "Nauvisian::Mod::Detail") do
  transient :downloads_count, :name, :owner, :summary, :title, :category, :created_at, :description
  downloads_count { Faker::Number.number(digits: 5) }
  name { Faker::Alphanumeric.alpha(number: 10) }
  owner { Faker::Internet.username }
  summary { Faker::Lorem.paragraph }
  title { Faker::Lorem.sentence }
  category { Faker::Lorem.word }
  created_at { Faker::Time.backward.utc }
  description { Faker::Lorem.paragraphs.join("\n") }
  initialize_with do |transients|
    resolved_class[**transients]
  end
end
