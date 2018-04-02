RSpec.describe Timebomb do
  it "has a version number" do
    expect(Timebomb::VERSION).not_to be nil
  end
end

RSpec.describe Timebomb::Bomb do
  let(:path) { "spec/timebombs/remove-experiment.tb" }
  let(:current_time) { Chronic.parse("Jan 1, 2010") }
  before { allow(::Timebomb).to receive(:current_time).and_return(current_time) }
  before { subject.parse_file path }
  subject { Timebomb::Bomb.new }
  it "has date" do
    expect(subject.date).to eql(Chronic.parse("Jan 1, 2050"))
  end
  it "has title" do
    expect(subject.title).to eql("Remove alpha flag")
  end
  it "has description" do
    expect(subject.description).to include("We put this in here to test some things and won't need it after 2050 rolls around.")
  end
  describe "#has_exploded?" do
    context "Jan 1, 3000" do
      let(:current_time) { Chronic.parse("Jan 1, 3000") }
      it "has not exploded" do
        expect(subject).not_to have_exploded
      end
    end
    context "Jan 1, 2000" do
      let(:current_time) { Chronic.parse("Jan 1, 2000") }
      it "has exploded" do
        expect(subject).to have_exploded
      end
    end
  end
end

RSpec.describe Timebomb::Suite do
  let(:paths) { Dir.glob("spec/timebombs/**/**.tb") }
  subject { Timebomb::Suite.new }
  before { subject.load_files(paths) }
  it "has_exploded" do
    expect(subject.has_exploded?)
  end
end
