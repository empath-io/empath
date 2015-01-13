require 'faker'

FactoryGirl.define do

  factory :subject do 
    experiment_id			1
    email							'tester@gmail.com'
    phone_number			'3059786705'
    name							'jared goodner'
  end

end
