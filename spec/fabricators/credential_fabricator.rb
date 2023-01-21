# frozen_string_literal: true

Fabricator(:credential, from: "Nauvisian::Credential") do
  transient :username, :token
  username { Faker::Internet.username }
  token { Faker::Number.hexadecimal(digits: 30) }
  initialize_with do |transients|
    resolved_class[**transients]
  end
end
