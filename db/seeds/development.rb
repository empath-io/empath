
god_user = User.find_by_email('jrgoodner@gmail.com')
if god_user.nil?
	god_user = User.create(:first_name => 'jared',:last_name=>'goodner',:email => 'jrgoodner@gmail.com',:login=>'jrgoodner',:password => 'whatever',:password_confirmation => 'whatever',:role => 'god',:default_trigger_time_zone=>"Pacific Time (US & Canada)")
end

# Create 5 experiments 
	# with 1 trigger
	# 	with 1 scheduled daily operation (SMS)
	# with 5 subjects
	# 	with 50 outgoing and incoming messages
consumption_array = ['coffee','OJ','chocolate','water'] # "How much ... did you consume today?"
compliance_array = ['situps','rubber band reps','pushups','pullups'] # "How many ... did you do today?"
5.times do
	experiment = Experiment.new(:name => Faker::Commerce.color, :user_id => god_user.id)
	experiment.save(:validate => false)
	3.times do
		trigger = Trigger.new(:experiment_id => experiment.id,:start_month => (rand*11).to_i+1, :start_day => 15, :start_year => 2013,:hour =>(rand*11).to_i+1, :minute => (rand*59).to_i,:am => false,:repeat => 'daily',:trigger_time_zone => "Pacific Time (US & Canada)")
		trigger.save(:validate => false)
		if !trigger.errors.empty?
			debugger
			puts "ERROR: #{trigger.inspect}"
		end		
		operation = Operation.new(:trigger_id => trigger.id,:name => Faker::Commerce.department, :kind => 'twilio_sms', :content =>"How much #{consumption_array[(rand*3).to_i]} did you consume today?" )
		operation.save(:validate => false)
		operation.update_attributes({:schedule_name => "operation_#{operation.id}"})
		if !operation.errors.empty?
			debugger
			puts "ERROR: #{operation.inspect}"
		end
		5.times do 
			puts "creating subject"
			first_name = Faker::Name.first_name
			# debugger
			s = Subject.new(:experiment_id => experiment.id,:email => Faker::Internet.email(first_name),:name =>"#{first_name.capitalize} #{Faker::Name.last_name.capitalize}",:phone_number => Faker::Number.number(10) )
			s.save(:validate => false)
			if !s.errors.empty?
				debugger
				puts "ERROR: #{s.inspect}"
			end
			first_message_time = Time.zone.now-15.days
			15.times do
				# Create outgoing message
				first_message_time = first_message_time + 1.days + (2+rand(3)).hours + rand(45).minutes
				m_o = Message.create(:created_at => first_message_time, :updated_at => first_message_time, :outgoing => true, :to_number =>s.phone_number,:from_number=>Rails.configuration.twilio[:from_number],:body => operation.content, :message_sid => Faker::Bitcoin.address, :status => 'delivered',:subject_id => s.id, :operation_id =>operation.id )
				# Pause for 50 msec
				# puts "sleeping in between messages"
				sleep(1.0/20.0)
				# Create incoming message
				m_i = Message.create(:created_at => first_message_time+1.minute, :updated_at => first_message_time+1.minute, :outgoing => false, :to_number =>s.phone_number,:from_number=>Rails.configuration.twilio[:from_number],:body => (rand*10).to_i, :message_sid => Faker::Bitcoin.address, :status => 'received',:subject_id => s.id, :operation_id =>operation.id)
				# debugger
				# puts m_i.inspect
			end # end message creation
		end# end 5.times subject creation
	end # end 3.times trigger creation
end