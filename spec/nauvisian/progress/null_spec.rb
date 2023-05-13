# frozen_string_literal: true

RSpec.describe Nauvisian::Progress::Null do
  let(:progress) { Nauvisian::Progress::Null.new }

  it "responds to progress=" do
    expect(progress).to respond_to(:progress=)
  end

  it "responds to total=" do
    expect(progress).to respond_to(:total=)
  end
end
