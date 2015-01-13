class Subject < ActiveRecord::Base

	belongs_to :experiment
	has_many :operations, :through => :experiment
	has_many :messages
  has_one :signup

  before_validation :format_phone_number
	after_save :update_operations

	validates :phone_number, uniqueness: { scope: :experiment_id,
    message: "has already been added to this experiment" }
  validates :name, presence: true

  private

  def format_phone_number
    # Strip out country code and non-number characters
    self.phone_number = PhoneNumber.format_as_empath_phone_number(phone_number)
  end

  def update_operations
  	self.operations.each do |o|
  		o.update_schedule([self.id])
  	end
  end


end
