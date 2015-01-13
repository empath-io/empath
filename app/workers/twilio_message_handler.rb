class TwilioMessageHandler
	
	@queue = :twilio_queue

	#TODO need error handling!!!
	def self.perform(operation_id,twilio_callback_url,subject_ids=[])
		# Twilio callback URL is either pulled from ENV (e.g. for development) or from root_url
		# twilio_callback_url = "#{ENV['TEMP_EXTERNAL_URL']}/twilio/incoming" || "#{root_url}/twilio/incoming"
		# Resque.logger.info "Within TwilioMessageHandler.....perform method"
		operation = Operation.find(operation_id)
		content = operation.content
		if subject_ids.empty?
			subjects = []
		else
			subjects = subject_ids.collect {|id| Subject.find(id)}
		end
		# Use Smsoperation class
		@sms_sender = Smsoperation.new('live') # get rid of argument for 'test' config      
		# For each subject, send an SMS via Smsoperation
		subjects.each do |s|
			# Twilio SMS API call
      message = @sms_sender.send_sms(s.phone_number,content,twilio_callback_url) 
      if message.is_a?(Twilio::REST::Message)  
	            # Create Message in DB
				m = Message.create({  
					:outgoing => true,
					:to_number=> message.to,
					:from_number=>message.from,
					:body=>message.body,
					:subject_id =>s.id,
					:operation_id=>operation.id,
					:message_sid => message.sid,
					:account_sid => message.account_sid
				}) 
				if Rails.env == 'development'
	      	# debugger
	      	puts "is a message"
	      end
			else
				Rails.logger.warn "Error sending Twilio Message: #{message.inspect}"
				if Rails.env == 'development'
					debugger
					puts "aint a message"
	      end
			end

    end # end subjects.each
	end

end