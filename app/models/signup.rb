class Signup < ActiveRecord::Base

	belongs_to :experiment
  belongs_to :user
  belongs_to :subject

  scope :today, -> {where("created_at >= ?", Time.zone.now.at_beginning_of_day).order(created_at: :desc)}
  scope :yesterday, -> {where("created_at >= ? AND created_at < ?", (Time.zone.now-24.hours).at_beginning_of_day,Time.zone.now.at_beginning_of_day).order(created_at: :desc)}
  scope :this_week, -> {where("created_at >= ?", Time.zone.parse(Date.commercial(Date.today.year, Date.today.cweek-1, 1).to_s)).order(created_at: :desc)}

end
