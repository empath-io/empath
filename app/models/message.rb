class Message < ActiveRecord::Base
  
	belongs_to :subject
	belongs_to :operation
	has_one :experiment, through: :subject

	before_save :remove_country_code
	before_save :deactivate_incoming_message_if_body_formatted_incorrectly
	
	after_create :perform_alerts

	scope :active, -> {where(active: true)}
	scope :incoming, -> {where(active: true, outgoing:false).order(created_at: :desc)}
	scope :outgoing, -> {where(active: true, outgoing:true).order(created_at: :desc)}
	scope :today, -> {where("created_at >= ?", Time.zone.now.at_beginning_of_day).order(created_at: :desc)}
	scope :not_including_today, -> {where("created_at < ?", Time.zone.now.at_beginning_of_day).order(created_at: :desc)}

	MAXVAL = 5


	def self.find_incoming_messages_over_time_ago(time)
		self.incoming.messages_over_time_ago(time)	
	end

	def self.find_incoming_messages_over_days_ago(num_days)
		self.incoming.messages_over_days_ago(num_days)
	end

	def self.messages_over_time_ago(time)
		self.where("created_at >= ?", Time.zone.now-time)	
	end

	def self.messages_over_days_ago(num_days)
		self.where("messages.created_at >= ?", Time.zone.now.at_beginning_of_day-num_days.days)	
	end

	# Returns a hash of binned objects (key is time for bin)
    # Arg time_duration should be 1.days, 1.second, 2.weeks, etc
	def self.bin_messages_with_time_as_key(messages_array,time_duration,time_zone)
		# Set time zone to current user's default time zone
		Time.zone = time_zone
		size_of_bin = time_duration.seconds # duration in seconds
		first_message = messages_array.min_by{|m| m.updated_at}
		# Subtracting two ActiveSupport::TimeWithZone objects results in difference in seconds 
		messages_array = messages_array.group_by{|m| ( (m.updated_at - first_message.updated_at)/size_of_bin ).to_i }
		# Create hash binned by seconds
		messages_array_binned_by_time = {}
		messages_array.each do |bin,mess_array|
			# FIXME this is a hack to ensure dashboard sees no messages that aren't numbers
			mess_array.each do |m|
				if m.body.to_f > 5 || m.body.to_f < 1
					mess_array.delete(m)
				end
			end
			# Get time (in seconds) for this bin
			key = mess_array.first.updated_at.to_i*1000
			messages_array_binned_by_time[key] = mess_array
		end
		return messages_array_binned_by_time
	end

	# Returns a hash of binned objects (key is bin number)
    # Arg time_duration should be 1.days, 1.second, 2.weeks, etc
	def self.bin_messages(messages_array,time_duration)
		size_of_bin = time_duration.seconds # duration in seconds
		first_message = messages_array.min_by{|m| m.updated_at}
		# Subtracting two ActiveSupport::TimeWithZone objects results in difference in seconds 
		messages_array.group_by{|m| ( (m.updated_at - first_message.updated_at)/size_of_bin ).to_i }
	end

	private

	def perform_alerts
		# Generate alerts for admin if incoming_message requires it
		if !outgoing && !operation.nil?
			debugger
			if operation.response_warrants_signal(body)
				Resque::Scheduler.dynamic = true
				if ENV['TEMP_EXTERNAL_URL']
					twilio_callback_url = "#{ENV['TEMP_EXTERNAL_URL']}/twilio/messages" 
				else
					twilio_callback_url = "#{ENV['APP_ROOT_URL']}/twilio/messages"
				end
				# Find operation admin
				admin = operation.admin
				if admin.phone_number
					debugger
					alert_content = "Empath Alert: incoming message alert for experiment: \"#{operation.experiment.name}\" operation: \"#{operation.name}\""
					# Enqueue alert message for NOW
					Resque.enqueue_at( Time.zone.now , TwilioAlertMessageHandler, alert_content, twilio_callback_url,[admin.phone_number])
				end # end if phone_number
			end # end if operation warrants signal
		end # end if operation exists

	end

	def deactivate_incoming_message_if_body_formatted_incorrectly
		if !self.outgoing
			body_as_float = self.body.to_f
			if (body_as_float == 0) || (body_as_float > Message::MAXVAL)
				self.active = false
			end
		end
		return true
	end

	def remove_country_code
		if self.to_number
			self.to_number = PhoneNumber.format_as_empath_phone_number(self.to_number)
		end
		if self.from_number
			self.from_number = PhoneNumber.format_as_empath_phone_number(self.from_number)
		end
		return true
	end

end