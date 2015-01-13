require 'rails_helper'

describe Subject do

  it "has a valid factory" do
    expect(build(:subject)).to be_valid
  end

  subject { build(:subject) }

  context "when subject is created without name" do
    before(:each) {subject.name = nil}

    specify { expect(subject).not_to be_valid }
  end  

  context "when subject is created using phone number with country codes" do
    before(:each) do
      subject.phone_number ='+13059786705'
    end

    it "the object's phone numbers contain no country code " do
      subject.send(:format_phone_number)
      expect(subject.phone_number).to eq('3059786705')
    end     
  end

  context "when subject is created using phone number with punctuation" do
    before(:each) do
      subject.phone_number ='(305)978-6-705'
    end

    it "the object's phone numbers contain no punctuation " do
      subject.send(:format_phone_number)
      expect(subject.phone_number).to eq('3059786705')
    end     
  end

end