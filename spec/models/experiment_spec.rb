require 'rails_helper'

describe Experiment do

  it "has a valid factory" do
    expect(build(:experiment)).to be_valid
  end

  subject { build(:experiment) }

  context "when experiment is created without a name" do
    before(:each) do
      subject.name=nil
    end

    specify { expect(subject).not_to be_valid }
  end

end