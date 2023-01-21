# frozen_string_literal: true

Fabricator(:mod, from: "Nauvisian::Mod") do
  transient :name
  name { Faker::Alphanumeric.alpha(number: 10) }
  initialize_with do |transients|
    resolved_class[name: transients[:name]]
  end
end
