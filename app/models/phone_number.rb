class PhoneNumber

	def self.format_as_empath_phone_number(num_str)
    # Strip out country code and non-number characters
    num_str.gsub(/^\+\d/,'').gsub(/\D/,'')
	end

end