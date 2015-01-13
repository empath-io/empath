require 'faker'

FactoryGirl.define do

  factory :user do 
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    login {Faker::Internet.user_name}
    email {Faker::Internet.email}
    role 'admin'
    default_trigger_time_zone "Pacific Time (US & Canada)"
    password 'whatever'
    password_confirmation 'whatever'
  end

end
