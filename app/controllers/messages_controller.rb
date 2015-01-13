class MessagesController < ApplicationController

	skip_before_filter :verify_authenticity_token 

	def incoming_message
		# Save incoming message
		incoming_message = Message.new(twilio_params.merge(outgoing: false))

		# Find most recent message (with no reply) that was sent to this phone number
		outgoing_message = Message.where(outgoing: true, to_number: PhoneNumber.format_as_empath_phone_number(incoming_message.from_number)).order(created_at: :desc).limit(1).first
		# Set incoming message subject and operation data accordingly
		# Update outgoing message.replied = true
		debugger
		if outgoing_message

			if !outgoing_message.replied
				# inactivate original incoming message
				operation = Operation.find(outgoing_message.operation_id)
				previous_incoming_message = operation.find_latest_incoming_message_from_subject(outgoing_message.subject_id)
				if previous_incoming_message
					previous_incoming_message.update_attributes({active: false})
				end
			end
			# Save incoming message
			incoming_message.subject_id = outgoing_message.subject_id
			incoming_message.operation_id = outgoing_message.operation_id
			incoming_message.save
			# Mark outgoing message as replied
			outgoing_message.update_attributes({:replied => true})

			# Look for send_as_response triggers associated with the incoming message's operation
			subject_id = incoming_message.subject_id
			operation = incoming_message.operation
			experiment = operation.experiment
			# Find all triggers in this experiment with preceding_operation_id = operation_id
			response_triggers = Trigger.where(experiment_id: experiment.id, preceding_operation_id: operation.id)
			# FIXME right now it only handles the first trigger found
			if !response_triggers.empty?
				debugger
				if ENV['TEMP_EXTERNAL_URL']
					twilio_callback_url = "#{ENV['TEMP_EXTERNAL_URL']}/twilio/messages" 
				else
					twilio_callback_url = "#{ENV['APP_ROOT_URL']}/twilio/messages"
				end				
				response_trigger = response_triggers.first
				# Find operation
				response_operation = response_trigger.operation
				# Enqueue operation for subject to start after response_trigger.interval has passed
				response_operation.enqueue(Time.zone.now + response_trigger.interval.minutes,twilio_callback_url,[subject_id])
			end
		else
			incoming_message.save
		end

		render nothing: true
	end

	def update_status
		# Find corresponding Message and update status
		m = Message.where('message_sid=?',params['MessageSid'])
		if !m.empty?
			m.first.update_attributes({:status => params['MessageStatus']})
		end
		render nothing: true
	end

	def deactivate
		@message = Message.find(params[:id])
		@message.active = false

    respond_to do |format|
			if @message.save
				format.js { render 'dashboard/deactivate' }
			else
      	@notice = "Sorry! Unable to deactivate message. Please try again or contact support."
				format.js { render 'dashboard/deactivate' }
			end
    end 
	end

	private

	def twilio_params
		hash = {:message_sid=>params[:MessageSid],
				:account_sid => params[:AccountSid],
				:from_number => params[:From],
				:to_number => params[:To],
				:body => params[:Body]
				}
	end
end
