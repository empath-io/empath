
god_user = User.find_by_email('jrgoodner@gmail.com')
if god_user.nil?
	god_user = User.create(:first_name => 'jared',:last_name=>'goodner',:email => 'jrgoodner@gmail.com',:login=>'jrgoodner',:password => 'whatever',:password_confirmation => 'whatever',:role => 'god')
end

# Create 5 experiments 
	# with 1 trigger
	# 	with 1 scheduled daily operation (SMS)
	# with 5 subjects
	# 	with 50 outgoing and incoming messages
consumption_array = ['coffee','OJ','chocolate','water'] # "How much ... did you consume today?"
compliance_array = ['situps','rubber band reps','pushups','pullups'] # "How many ... did you do today?"
5.times do
	experiment = Experiment.where(:name => Faker::Commerce.color, :user_id => god_user.id).first_or_create
	trigger = Trigger.where(:experiment_id => experiment.id,:start_month => (rand*11).to_i+1, :start_day => 15, :start_year => 2013,:hour =>(rand*11).to_i+1, :minute => (rand*59).to_i,:am => false,:repeat => 'daily',:trigger_time_zone => "Pacific Time (US & Canada)").first_or_create
	operation = Operation.create(:trigger_id => trigger.id,:name => Faker::Commerce.department, :kind => 'twilio_sms', :content =>"How much #{consumption_array[(rand*3).to_i]} did you consume today?" )
	operation.update_attributes({:schedule_name => "operation_#{operation.id}"})
	5.times do 
		first_name = Faker::Name.first_name
		s = Subject.create(:experiment_id => experiment.id,:email => Faker::Internet.email(first_name),:first_name =>first_name,:last_name => Faker::Name.last_name,:phone_number => Faker::Number.number(10) )
		50.times do
			# Create outgoing message
			m_o = Message.create(:outgoing => true, :to_number =>s.phone_number,:from_number=>Rails.configuration.twilio[:from_number],:body => operation.content, :message_sid => Faker::Bitcoin.address, :status => 'delivered',:subject_id => s.id)
			# Pause for 50 msec
			puts "sleeping in between messages"
			sleep(1.0/20.0)
			# Create incoming message
			m_i = Message.create(:outgoing => false, :to_number =>s.phone_number,:from_number=>Rails.configuration.twilio[:from_number],:body => (rand*10).to_i, :message_sid => Faker::Bitcoin.address, :status => 'received',:subject_id => s.id)
		end # end message creation
	end
end