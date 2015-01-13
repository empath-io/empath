class TwilioAlertMessageHandler
	
	@queue = :twilio_queue

	#TODO need error handling!!!
	def self.perform(content,twilio_callback_url,phone_number_array)
		# Use Smsoperation class
		@sms_sender = Smsoperation.new('live') # get rid of argument for 'test' config      
		# For each subject, send an SMS via Smsoperation
		phone_number_array.each do |p|
			# Twilio SMS API call
      message = @sms_sender.send_sms(p,content,twilio_callback_url) 
      if message.is_a?(Twilio::REST::Message)  
	            # Create Message in DB
				Rails.logger.info "Alert message sent: #{message.inspect}"
			else
				debugger
				# Rails.logger.warn "Error sending Twilio Message: #{message.inspect}"
				Rails.logger.error "Alert message UNABLE TO SEND: #{message.inspect}"
			end

    end # end subjects.each
	end

end