require 'faker'

FactoryGirl.define do

  factory :message do 
    outgoing        true
    to_number       '3059786705'
    from_number     '3105100000'
    body            'Is this a question?'
    message_sid     '123123123abcdefghijklmnop'
  end

end
