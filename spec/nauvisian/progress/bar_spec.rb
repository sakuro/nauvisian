# frozen_string_literal: true

RSpec.describe Nauvisian::Progress::Bar do
  let(:progress) { Nauvisian::Progress::Bar.new }
  let(:bar) { instance_double(ProgressBar::Base) }

  before do
    allow(ProgressBar).to receive(:create).and_return(bar)
    allow(bar).to receive(:progress=)
    allow(bar).to receive(:total=)
  end

  it "sets progress of the internal progress bar" do
    progress.progress = 50
    expect(bar).to have_received(:progress=).with(50)
  end

  it "sets total of the internal progress bar" do
    progress.total = 100
    expect(bar).to have_received(:total=).with(100)
  end
end
