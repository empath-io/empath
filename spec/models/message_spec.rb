require 'rails_helper'

describe Message do

  it "has a valid factory" do
    expect(build(:message)).to be_valid
  end

  subject { build(:message) }

  context "when message is created using phone numbers with country codes" do
    before(:each) do
      subject.to_number ='+13059786705'
      subject.from_number= '+13050786705'
    end

    it "the object's phone numbers contain no country code " do
      subject.send(:remove_country_code)
      (expect(subject.to_number).to eq('3059786705')) && \
        (expect(subject.from_number).to eq('3050786705'))
    end     
  end

  context "when incoming message body is in incorrect format" do
    before(:each) do
      subject.outgoing = false
      subject.body = "string"
    end
    
    specify { expect(subject.valid?).to eq(true) }
    it "attr 'active' is set to 'inactive'" do
      subject.send(:ensure_incoming_message_body_format)
      expect(subject.active).to eq(false)
    end
  end

  context "when incoming message body is correct format but BEYOND the max value limit" do
    before(:each) do 
      subject.outgoing = false
      subject.body = '20'
    end

    specify { expect(subject.valid?).to eq(true) }
    it "attr 'active' is set to 'inactive'" do
      subject.send(:ensure_incoming_message_body_format)
      expect(subject.active).to eq(false)
    end
  end  
 
  context "when incoming message body is correct format but BELOW the max value limit" do
    before(:each) do
      subject.outgoing = false
      subject.body = '0'
    end

    specify { expect(subject.valid?).to eq(true) }
    it "attr 'active' is set to 'inactive'" do
      subject.send(:ensure_incoming_message_body_format)
      expect(subject.active).to eq(false)
    end
  end  

end