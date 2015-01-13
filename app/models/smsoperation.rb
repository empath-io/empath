require 'twilio-ruby'

class Smsoperation < Operationtype

	def initialize(live_str='test')
		# Resque.logger.info "Within SMSOperation\nlive_str=#{live_str}\n"
	  @type = 'smsoperation'
	  @twilio_client = return_twilio_instance(live_str)
	end

	def send_sms(to_number,body,callback_url='')
	  # no warnings for any use of deprecated methods here
	  if Rails.env == 'development'
		  puts "*****FROM number: #{ENV['TWILIO_NUMBER']}\n******Account Sid: #{ENV['TWILIO_LIVE_API_ACCOUNT_SID']}\n******Account token: #{ENV['TWILIO_LIVE_API_AUTH_TOKEN']}"
		end
		ActiveSupport::Deprecation.silence do
			begin
				message = @twilio_client.account.messages.create(
				  :from => ENV['TWILIO_NUMBER'],
				  :to => to_number,
				  :body => body,
				  :StatusCallback => callback_url
				)
				return message
			rescue Twilio::REST::RequestError => e
			    return e
			end
		end
	end

	private

		# Returns twilio client with test configuration unless live_str == 'live'
		def return_twilio_instance(live_str)
				# Resque.logger.info "live_str == 'live'\n"				
				return Twilio::REST::Client.new(ENV['TWILIO_LIVE_API_ACCOUNT_SID'],ENV['TWILIO_LIVE_API_AUTH_TOKEN'])	
		end


end