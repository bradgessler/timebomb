RSpec.describe Timebomb do
  it "has a version number" do
    expect(Timebomb::VERSION).not_to be nil
  end
end

RSpec.describe Timebomb::Timebomb do
  let(:path) { "spec/timebombs/remove-experiment.tb" }
  subject { Timebomb::Timebomb.new }
  before { subject.parse_file path }
  it "has date" do
    expect(subject.date).to eql(Chronic.parse("Jan 1, 2050"))
  end
  it "has title" do
    expect(subject.title).to eql("Remove alpha flag")
  end
  it "has notes" do
    expect(subject.notes).to include("We put this in here to test some things and won't need it after 2050 rolls around.")
  end
  describe "#has_exploded?" do
    it "has exploded if date past" do
      expect(subject.has_exploded?(current_time: Chronic.parse("Jan 1, 3000")))
    end
    it "has not exploded if date has not past" do
      expect(subject.has_exploded?(current_time: Chronic.parse("Jan 1, 2000")))
    end
  end
end

RSpec.describe Timebomb::Suite do
  let(:paths) { Dir.glob("spec/timebombs/**/**.tb") }
  subject { Timebomb::Suite.new }
  before { subject.load_files(paths) }
  it "has_exploded" do
    expect(subject.has_exploded?(current_time: Chronic.parse("Jan 1, 2018")))
  end
end
