class Notifier < ActionMailer::Base
	
  default_url_options[:host] = "localhost"
  default from: "Concierge Desk"
  
  def password_reset_instructions(user)
  	url = edit_password_reset_url(user.perishable_token)
  	mail(to: user.email, subject: "Password Reset Instructions", body: url)
  end
end