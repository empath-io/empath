class Organization < ActiveRecord::Base

	has_many :users
	has_many :employees, -> { where role: 'employee' } ,class_name: "User"
	has_many :admins, -> { where role: 'admin' }, class_name: "User"

	has_many :experiments, through: :users

end