# frozen_string_literal: true

RSpec.describe Nauvisian do
  it "has an inflector" do
    expect(Nauvisian.inflector).to be_an_instance_of(Dry::Inflector)
  end

  it "has a version number" do
    expect(Nauvisian::VERSION).not_to be_nil
  end
end
