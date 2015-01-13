class DashboardController < ApplicationController
	before_filter :require_user
	before_action :set_experiment	
	before_action :set_plot_vars
	before_action :set_breadcrumb

	def show


		@todays_message_count = @experiment.todays_messages.count
		@operations = @experiment.operations
		# Generate color array
		colors_available = ["#92d5ea", "#666699", "#be1e2d", "#ee8310", "#8d10ee"]
		@colors_by_op  = []
		@operations.each_with_index do |o,i|
			@colors_by_op << colors_available[i%4]
		end

		# Params 
		#  start_time (Time object)
		#  end_time (Time object)
		#  bin_type ('day','hour')

		# For each operation, generate a hash of responses binned by day
		o_hash_responses = {}
		o_array_responses = []
		@o_array_keys = []

		exp_hash = {}
		exp_keys = []		
		@operations.each do |o|
			# Get responses to incoming messages and bin them by day of response
			incoming_messages = o.incoming_messages.where("updated_at >= :start_date AND updated_at <= :end_date",{start_date: @start_time, end_date: @end_time})
			binned_messages_hash = Message.bin_messages_with_time_as_key(incoming_messages,@bin_size,current_user.default_trigger_time_zone)
			# Rails.logger.warn("@start_time: #{@start_time} @end_time: #{@end_time}\nincoming_messages.count = #{incoming_messages.count}\nBinned_messages_hash: #{binned_messages_hash.inspect}")
			# debugger
			# debugger
			operation_hash = {}
			operation_arrays = []
			operation_keys = []
			# For each bin, convert the message array into an array of response values
			binned_messages_hash.each do |bin,messages_array|
				operation_hash[bin] = convert_message_array_into_response_value_array(messages_array)
				operation_arrays << operation_hash[bin]
				# debugger
				operation_keys << bin
			end
			# Place each operation's data into the exp hash / array
			exp_hash[o.id] = operation_hash
			exp_keys << operation_keys
		end
		# debugger
		exp_arrays = convert_experiment_hash_into_data_pairs(exp_hash)
		# Calculate average for each bin
		exp_arrays_avg = []
		exp_keys_avg = []
		# For each operation
		exp_hash.each do |key,responses|
			# For each bin, calculate average and place it in avg_response_array
			operation_avg_array = []
			# Set average as avg_hash value and bin as avg_hash key
			responses.each do |bin,resp_array| 
				operation_avg_array << [bin,resp_array.sum/resp_array.length]
			end
			exp_arrays_avg << operation_avg_array.sort # sorts by ascending key
			exp_keys_avg << key
			# debugger
		end
		# debugger
		# Return appropriate data based on plot_type
		if @data_type == 'all'
			@data = exp_arrays
			@keys = exp_keys
		elsif @data_type == 'avg' 
			@data = exp_arrays_avg
			@keys = exp_keys_avg
		else
			@data = []
			@keys = []
		end	

		@data_as_json = @data.to_json
		@keys_as_json = @keys.to_json

		respond_to do |format|
			format.html
			format.js
		end   
	end

	def init_phone_call
		debugger
		@subject = Subject.find(params[:subject_id])

		if current_user && !(current_user.phone_number.nil? || current_user.phone_number.empty?)
			TwilioCall.create_call_between_two_phones(current_user.phone_number,@subject.phone_number)
			@notice = "Patching a call between your phone (#{current_user.phone_number}) and #{@subject.name.capitalize}'s (#{@subject.phone_number})"
		else
			# make known that admin needs to add their phone number
			url = edit_user_path(current_user)
			@notice = "To use this function, you need to add your phone number by clicking <a href=\"#{url}\">here</a>."
		end

		respond_to do |format|
			format.js
		end   
	end

	private

		def set_breadcrumb
			@breadcrumb = []
			@breadcrumb << ['Dashboard',experiments_path]
			@breadcrumb << ["Exp: #{@experiment.name.capitalize}",'']
		end

    def set_experiment
      if params[:experiment_id]
        @experiment = Experiment.find(params[:experiment_id])
      end
    end

    def set_plot_vars
    	# Set @bin_type ('day' or 'hour')
		@bin_type = params[:bin_type] || 'month'
		# Set @data_type ('avg' or 'all')
		@data_type = params[:data_type] || 'avg'

		# Set @bin_size and @time_format
		case @bin_type
		when 'day'
			@bin_size = 1.day
			@time_format = "%m/%d"
		when 'hour'
			@bin_size = 1.hour
			@time_format = "%m/%e %I:%M %p"
		when 'minute'
			@bin_size = 1.minute
			@time_format = "%m/%e %I:%M %p"
		else
			@bin_size = 1.day
			@time_format = "%m/%d"
		end				

		# Set plot bounds
		Time.zone = current_user.default_trigger_time_zone
		if params[:start_time] && params[:end_time]
			@start_time = Time.zone.at(params[:start_time].to_i)
			@end_time = Time.zone.at(params[:end_time].to_i)
		else
			@start_time = Time.zone.at(0)
			@end_time = Time.zone.now
		end
    end

    def convert_message_array_into_response_value_array(messages_array)
		values_array = messages_array.collect do |m|
				if is_int?(m.body)
					m.body.to_i 
				else
					0 # Temporary - need a better way to indicate an improper response (such that the zero doesn't affect the stats)
				end
			end
		return values_array
    end

    def convert_experiment_hash_into_data_pairs(hash)
    	ops_array = []
    	hash.each do |op,h|
    		# debugger
    		data_pairs = []
    		h.each do |time,responses|
    			data_pairs.concat(responses.collect{|r| [time,r]})
    		end
    		ops_array << data_pairs
    	end
    	return ops_array
    end


end
