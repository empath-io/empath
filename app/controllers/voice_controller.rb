class VoiceController < ApplicationController

	skip_before_filter :verify_authenticity_token 

	def connect_call
		# debugger
		# puts params.inspect
		@num_to_connect = params['empath_to_number']
		puts "within voice call"
	  render :action => "connect_call.xml.rb", :layout => false
	end

end

# params from twilio
# {"AccountSid"=>"AC2d5d8876f489ff28e8e1a8d02bf878e7", "ToZip"=>"33033", "FromState"=>"CA", "Called"=>"+13059786705", "FromCountry"=>"US", "CallerCountry"=>"US", "CalledZip"=>"33033", "Direction"=>"outbound-api", "FromCity"=>"", "CalledCountry"=>"US", "CallerState"=>"CA", "CallSid"=>"CAcd9a9514bc757d14c5cbd3956b0420ed", "CalledState"=>"FL", "From"=>"+14158586923", "CallerZip"=>"", "FromZip"=>"", "CallStatus"=>"in-progress", "ToCity"=>"MIAMI", "ToState"=>"FL", "To"=>"+13059786705", "ToCountry"=>"US", "CallerCity"=>"", "ApiVersion"=>"2010-04-01", "Caller"=>"+14158586923", "CalledCity"=>"MIAMI", "controller"=>"voice", "action"=>"connect_call"}