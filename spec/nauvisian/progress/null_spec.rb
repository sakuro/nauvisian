# frozen_string_literal: true

RSpec.describe Nauvisian::Progress::Null do
  let(:release) { Fabricate(:release) }
  let(:progress) { Nauvisian::Progress::Null.new(release) }

  it "responds to progress=" do
    expect(progress).to respond_to(:progress=)
  end

  it "responds to total=" do
    expect(progress).to respond_to(:total=)
  end
end
