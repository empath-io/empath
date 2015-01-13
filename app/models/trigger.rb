class Trigger < ActiveRecord::Base
	
	belongs_to :experiment
	has_one :operation, dependent: :destroy, inverse_of: :trigger

	before_validation :ensure_delayed_trigger_includes_hours_and_minutes
	after_save :update_all_operation_schedules

	validates_inclusion_of :trigger_time_zone, :in => ActiveSupport::TimeZone.zones_map { |m| m.name }, :message => "is not a valid Time Zone"
	validate :trigger_time_is_in_future
	validate :send_after_includes_hours_and_minutes



	REPEATS = %w[none daily send_after send_as_response send_today_at]	

	TIMEZONES = {	
					"Pacific Time (US & Canada)"=>"PST", 
					"Central Time (US & Canada)"=>"CST", 
					"Mountain Time (US & Canada)"=>"MST", 
					"Eastern Time (US & Canada)"=>"EST"
				}

	def send_immediately?
		case self.repeat
		when "send_after"
			if (self.hour == 0 && self.minute == 0)
				true
			else
				false
			end
		when "send_as_response"
			if (self.minute == 0)
				true
			else
				false
			end
		else
			false
		end
	end

	def set_trigger_time_to(time)
		if self.trigger_time_zone
			Time.zone = self.trigger_time_zone
			if time >= Time.zone.now
				self.hour = convert_24_hour_into_12(time.hour)
				self.minute = time.min
				self.start_day = time.day
				self.start_month = time.month
				self.start_year = time.year
				self.am = is_am?(time.hour)
				self.save
			else
        errors.add(:trigger, "Trigger time must be in future")
        return false
      end
		end
	end

	def convert_24_hour_into_12(hour)
		if hour > 12
			return hour-12
		else
			return hour
		end
	end

	def is_am?(hour)
		if hour >= 12
			false
		else
			true
		end		
	end

	def get_start_hour_24
		if am
			if self.hour == 12
				return 0
			else
				return self.hour
			end
		else
			if self.hour == 12
				return 12
			else
				return self.hour + 12
			end
		end
	end

	private

		# Validate that send_after trigger type includes hours and/or minutes
		def send_after_includes_hours_and_minutes
			if self.repeat == 'send_after'
				if self.hour.nil? && self.minute.nil?
	        errors.add(:trigger, "Response time must include hours and/or minutes.")
	        return false
	      end
	    end
		end

		# If send_after trigger doesn't have hours or minutes set (e.g. params came in without values), set to zero.
		# Only sets one or the other. If both are nil or empty, the validate :send_after_includes_hours_and_minutes method will throw error.
		def ensure_delayed_trigger_includes_hours_and_minutes
			if self.repeat == 'send_after'
				# If either hour or minute are empty, set them to zero. If both are empty, 
				if self.hour.nil? && !self.minute.nil?
					self.hour = 0
				elsif self.minute.nil? && !self.hour.nil?
					self.minute = 0
				end
			end
		end

		# If trigger repeat is of type 'none' or 'daily', validate that the trigger time is in future
		def trigger_time_is_in_future
			if ['none','daily'].include? self.repeat
				begin
					Time.zone = self.trigger_time_zone
					start_date = Time.zone.local(self.start_year,self.start_month,self.start_day,self.get_start_hour_24,self.minute,0)
				rescue ArgumentError => e
					logger.warn "Trigger.rb: trigger_time_is_in_future\nAttempt to use invalid time zone: #{self.inspect}\n"
					errors.add(:trigger, "Time zone must be valid")
					return false
				rescue => e
					logger.warn "Trigger.rb: trigger_time_is_in_future\nAttempt to use invalid time: #{self.inspect}\n"					
					errors.add(:trigger, "Time must be valid")
					return false
				end
				if (start_date - Time.now) < 0
	        errors.add(:trigger, "Start date must be in future")
	        return false
	      end				
			end
		end

		def update_all_operation_schedules
			if operation
				self.operation.update_schedule
			end
		end

end
