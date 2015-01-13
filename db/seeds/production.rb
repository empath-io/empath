god_user = User.find_by_email('jrgoodner@gmail.com')
if god_user.nil?
	god_user = User.create(:first_name => 'jared',:last_name=>'goodner',:email => 'jrgoodner@gmail.com',:login=>'jrgoodner',:password => 'fuggit85',:password_confirmation => 'fuggit85',:role => 'god',:default_trigger_time_zone=>"Pacific Time (US & Canada)")
end