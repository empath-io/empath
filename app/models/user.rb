class User < ActiveRecord::Base

	acts_as_authentic
	belongs_to :organization
	has_many :experiments
	has_many :favorites
	has_many :favorite_activities, :through=> :favorites, :source => :activity
	has_many :bookings, -> { includes [:activity => [:vendor], :tickets => [:price => [:commission]]] }
	has_many :signups


	before_save :format_phone_number
	before_save :ensure_god_has_no_organization

	scope :employees, -> { where(role: 'employee') }
	scope :admins, -> { where(role: 'admin') }

	validates :first_name,:last_name,:role,:login,:email,:default_trigger_time_zone, presence: true

	ROLES = %w[god admin employee concierge]	
	
	validates_inclusion_of :role, :in => User::ROLES, :message => "is not a valid user role"

	def self.search_by_name(term)
		matches = Soulmate::Matcher.new('user').matches_for_term(term)
		matches.collect {|match| {"id" => match["id"], "label" => match["term"], "value" => match["term"]} }
	end


	def full_name
		"#{first_name.capitalize} #{last_name.capitalize}"
	end

	def is_god?
		self.role?('god')
	end

	def is_admin?
		self.role?('admin')
	end

	def is_employee?
		self.role?('employee')
	end

	def is_concierge?
		self.role?('concierge')
	end	


	def member_of?(object)
		if is_god?
			true
		else
			if object.is_a?(Organization)
				organization.id == object.id
			else
				false
			end
		end
	end

	def role?(r) 
		if self.role == r 
			return true
		else
			return false
		end
	end

	#Password reset stuff
	def deliver_password_reset_instructions!  
		reset_perishable_token!  
		Notifier.password_reset_instructions(self).deliver
	end  	

	private


	def format_phone_number
		if phone_number
			self.phone_number = PhoneNumber.format_as_empath_phone_number(phone_number)
		end
	end

	def ensure_god_has_no_organization
		if self.is_god? && !self.organization_id.nil?
			self.organization_id = nil
		end
	end
	
end