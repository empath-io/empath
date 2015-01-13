class Experiment < ActiveRecord::Base

	belongs_to :user
	has_many :subjects, -> {includes :messages}
	has_many :triggers
	has_many :operations, :through => :triggers
	has_many :incoming_messages, :through => :operations
	has_many :signups


	validates :name, presence: true

	def todays_messages
		incoming_messages.find_incoming_messages_over_days_ago(0)
	end

	def show_custom_field(name)
		if self.send(name).nil? || self.send(name).empty?
			false
		else
			true
		end
	end

end
