require 'faker'

FactoryGirl.define do

  factory :trigger do 
    experiment_id   1
    start_month     4
    start_day       21
    start_year      2016
    hour            5
    minute          15
    am              false
    repeat          'none'
    interval        0
    trigger_time_zone   "Pacific Time (US & Canada)"
  end

end
