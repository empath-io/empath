require 'rails_helper'

describe Trigger do
  it "has a valid factory" do
    expect(build(:trigger)).to be_valid
  end

  it "is valid if trigger time is in future" do
  	trigger = build(:trigger,start_day:Time.zone.now.day+1,start_month: Time.zone.now.month,start_year: Time.zone.now.year)

  	expect(trigger).to be_valid
  end

  it "is NOT valid if trigger time is missing the year" do
    trigger = build(:trigger,start_day:Time.zone.now.day-1,start_month: Time.zone.now.month,start_year: nil)

    expect(trigger).not_to be_valid
  end    

  it "is NOT valid if trigger time is improperly formatted" do
    trigger = build(:trigger,start_day:"a_string",start_month: Time.zone.now.month,start_year: Time.zone.now.year)

    expect(trigger).not_to be_valid
  end     

  it "is NOT valid if trigger time is NOT in future" do
    trigger = build(:trigger,start_day:Time.zone.now.day-1,start_month: Time.zone.now.month,start_year: Time.zone.now.year)

    expect(trigger).not_to be_valid
  end  

  it "is NOT valid if time zone isn't specified" do
    trigger = build(:trigger, trigger_time_zone: nil)

    expect(trigger).not_to be_valid
  end  

  it "is NOT valid if time zone isn't within ActiveSupport::TimeZone" do
    trigger = build(:trigger, trigger_time_zone: "fake time zone")

    expect(trigger).not_to be_valid
  end  

end