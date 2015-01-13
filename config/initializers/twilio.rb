# Change this value in the appropriate config/environments/ file
Rails.configuration.twilio = {
	# put your own credentials here
	:account_sid => ENV['TWILIO_API_ACCOUNT_SID'],
	:auth_token => ENV['TWILIO_API_AUTH_TOKEN'],
	:from_number => ENV['TWILIO_NUMBER']
}