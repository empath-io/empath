require 'twilio-ruby'

class TwilioCall

	HOME_URL= (if (Rails.env == "development") then ENV['TEMP_EXTERNAL_URL'] else ENV['APP_ROOT_URL'] end)

	def self.create_call_between_two_phones(from_number,to_number)
		phone_num_1 = from_number
		phone_num_2 = to_number
		callback_url = "#{HOME_URL}/twilio/voice_call?empath_to_number=#{phone_num_2}"
		TwilioCall.create_call(ENV['TWILIO_NUMBER'],phone_num_1,callback_url)
	end

	# phone numbers strings and include country code "+1...."
	def self.create_call(from_number,to_number,callback_url)

		account_sid = ENV['TWILIO_LIVE_API_ACCOUNT_SID']
		auth_token = ENV['TWILIO_LIVE_API_AUTH_TOKEN']
		 
		# set up a client to talk to the Twilio REST API
		@client = Twilio::REST::Client.new account_sid, auth_token
		 
		@call = @client.account.calls.create(
		  :from => "+1#{PhoneNumber.format_as_empath_phone_number(from_number)}",   # From your Twilio number
		  :to => "+1#{PhoneNumber.format_as_empath_phone_number(to_number)}",     # To any number
		  # Fetch instructions from this URL when the call connects
		  :url => callback_url
		)		

	end

	private

	def return_twilio_client
		account_sid = ENV['TWILIO_LIVE_API_ACCOUNT_SID']
		auth_token = ENV['TWILIO_LIVE_API_AUTH_TOKEN']
		 
		# set up a client to talk to the Twilio REST API
		@client = Twilio::REST::Client.new account_sid, auth_token
	end

end