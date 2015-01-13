class Operation < ActiveRecord::Base

	belongs_to :trigger, inverse_of: :operation
	has_one :experiment, :through => :trigger
	has_many :subjects, -> {includes :messages},:through => :experiment
	has_many :messages, -> { includes :subject }
	has_many :incoming_messages, -> { incoming }, :class_name => "Message", :foreign_key => 'operation_id' 

	has_one :admin, :through => :experiment, :source => :user

	validates :name, length: { maximum: 255 }

	# before_create :ensure_this_only_operation_for_trigger

	KINDS = %w[twilio_sms]	
	ALERT_CONTEXTS = %w[< > ==]

	def response_warrants_signal(response_str)
		# If response_str < 0, return false
		if alert_threshold.nil? || alert_threshold.empty? || (response_str.to_f < 0) 
			return false
		else
		# Otherwise, check the self.alert_context for what operation to run on the response_str
			case alert_context
				when '<'
					if (response_str.to_f < alert_threshold.to_f) then true else false end
				when '>'
					if (response_str.to_f > alert_threshold.to_f) then true else false end
				when '=='
					if (response_str.to_f == alert_threshold.to_f) then true else false end
				else
					false
			end # end case
		end # end if
	end	

	def avg_responses_in_past(num_days)
		messages = self.messages.find_incoming_messages_over_days_ago(num_days)
		# messages = self.messages.incoming.where("created_at >= ?", Time.zone.now.beginning_of_day-num_days.days)
		if !messages.empty?
			MathTask.avg( messages.collect{|m| m.body.to_f} )
		else
			0
		end
	end

	def find_incoming_messages_in_past(num_days)
		self.messages.find_incoming_messages_over_days_ago(num_days)		
	end

	def find_latest_incoming_message_from_subject(subject_id)
		self.messages.incoming.where(:subject_id => subject_id).order(created_at: :desc).limit(1).first
	end

	def incoming_messages_x
		messages.incoming
	end	

	def update_schedule(subjects=[])
		Resque::Scheduler.dynamic = true
		if ENV['TEMP_EXTERNAL_URL']
			twilio_callback_url = "#{ENV['TEMP_EXTERNAL_URL']}/twilio/messages" 
		else
			twilio_callback_url = "#{ENV['APP_ROOT_URL']}/twilio/messages"
		end
		if kind == 'twilio_sms'
			trigger = self.trigger
			# FIXME ensure that start_date is beyond NOW
			# Set trigger's time zone
			Time.zone = trigger.trigger_time_zone
			# time_zone = ActiveSupport::TimeZone.new(trigger.trigger_time_zone) # get timezone according to trigger attribute

			if trigger.repeat == 'none'
				subjects.each do |s_id|
					# Remove old scheduled jobs
					Resque.remove_delayed(TwilioMessageHandler, self.id, twilio_callback_url,[s_id])
					# Schedule a delayed job to perform operation
					# TODO ensure the start date is in correct time zone
					start_date = Time.zone.local(Time.zone.now.year,trigger.start_month,trigger.start_day,trigger.get_start_hour_24,trigger.minute,0)
					# enqueue operation for subject
					self.enqueue(start_date,twilio_callback_url,[sid])
				end

			elsif trigger.repeat == 'send_today_at'	
				# Schedule a job delayed by specified hours beyond subject signup if no message has already been sent (for each subject)
				subjects.each do |s_id|
					# if this operation's message hasn't been sent, schedule a message
					Resque.remove_delayed(TwilioMessageHandler, self.id, twilio_callback_url,[s_id])
					start_date = Time.zone.local(Time.zone.now.year,Time.zone.now.month,Time.zone.now.day,trigger.get_start_hour_24,trigger.minute,0)
					# enqueue operation
					self.enqueue(start_date,twilio_callback_url,[s_id])
				end		

			elsif trigger.repeat == 'send_as_response'	
				# Do nothing -- MessagesController#incoming_message handles scheduling these operations

			elsif trigger.repeat == 'send_after'
				# Schedule a job delayed by specified hours beyond subject signup if no message has already been sent (for each subject)
				subjects.each do |s_id|
					# if this operation's message hasn't been sent, schedule a message
					if Message.where(:outgoing => true, :subject_id => s_id, :operation_id => self.id).empty?
						subject= Subject.find(s_id)
						Resque.remove_delayed(TwilioMessageHandler, self.id, twilio_callback_url,[s_id])
						start_date = Time.zone.at(subject.created_at) + trigger.hour.hours + trigger.minute.minutes
						# enqueue operation
						self.enqueue(start_date,twilio_callback_url,[s_id])
					end
				end
				
			else # trigger.repeat == 'daily'
				# Remove old scheduled jobs
				Resque.remove_delayed(TwilioMessageHandler, self.id, twilio_callback_url)
				start_date = Time.zone.local(trigger.start_year,trigger.start_month,trigger.start_day,trigger.get_start_hour_24,trigger.minute,0)				
				if start_date > Time.zone.now
					# Schedule a daily job to perform operationS
					name = "operation_#{self.id}"
					config = {}
					config[:class] = 'TwilioMessageHandler'
					config[:args] = [self.id,twilio_callback_url]
					# config[:every] = ['24h', {first_in: (start_date-Time.zone.now).to_i.seconds}]
					config[:every] = ['24h', {first_at: start_date}]
					config[:persist] = true
					Resque.set_schedule(name, config)          
					self.update_attributes({schedule_name: name})
				end
			end
			# Reset Time.zone
			Time.zone = "UTC"
		end
	end

	# Sets up operation in delayed queue. Does nothing if start time is not in future.
	def enqueue(start_date,callback_url,subjects)
		if (start_date > Time.zone.now) || self.trigger.send_immediately?
			Resque.enqueue_at( start_date , TwilioMessageHandler, self.id, callback_url,subjects)
		end
	end

	def is_type?(type_str)
		if type_str == self.kind
			return true
		else
			return false
		end
	end

	protected

	def	ensure_this_only_operation_for_trigger
		if self.trigger.operation.nil?
			true
		else 
      errors.add(:operation, "Only one operation allowed per trigger. Please delete the any other operations for this trigger and try again.")
			false
		end
	end



end
