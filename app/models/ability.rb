class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new   # guest user

    # Abilities all users have


    
    if user.role? 'god'

      can :manage, :all

    elsif user.role? 'admin'    #concierge admin

      # ###########
      # # Bookings: 
      # # Concierge admins can manage their organization's Bookings
      # # Vendor admins can read their organization's activity bookings
      # can [:read], Booking do |booking|
      #   if user.belongs_to_vendor?
      #     user.member_of?(booking.vendor)
      #   elsif user.belongs_to_concierge?
      #     booking.user.member_of?(user.organization)
      #   else
      #     false
      #   end
      # end

      # can :create, Booking if user.belongs_to_concierge?

      # can :autocomplete_on_guest_or_activity_or_vendor_name, Booking if user.belongs_to_concierge?
      # can :update_browse_bookings, Booking if user.belongs_to_concierge?

      # can [:update,:destroy], Booking do |booking| 
      #   if user.belongs_to_concierge?
      #     booking.user.member_of?(user.organization)
      #   else
      #     false
      #   end
      # end

      # ###########
      # # Experiment: 
      # # Admin users can manage their employees' experiments and their own experiments
      can :manage, Experiment do |experiment|
        (experiment.user_id == user.id) || experiment.user.member_of?(user.organization)
      end

      can :manage, Trigger do |trigger|
        trigger.experiment.user_id == user.id
      end

      can :manage, Operation do |operation|
        operation.experiment.user_id == user.id
      end      

      can :manage, Subject do |subject|
        subject.experiment.user_id == user.id
      end            

      # can :create, Activity if user.belongs_to_vendor?

      ###########
      # Users
      # Can create new employee and admin users 
      # Can read/edit/delete users that are within user's organization
      can :create, User
      can [:read,:update,:destroy], User, :organization_id => user.organization_id

      # ###########
      # # Organizations:
      # # Can read,edit,destroy the organization as long as user is the admin
      can [:read,:update,:destroy], Organization, :id => user.organization_id       

      # ###########
      # # Vendors:
      # # Can read,edit,destroy the organization as long as user is the admin
      # can [:read,:update,:destroy], Vendor, :id => user.organization_id  

      # ###########
      # # Desks
      # # Only a concierge admin can read, udpate, destroy desks that his org owns
      # can :manage, Desk, :organization_id => user.organization_id

      # ###########
      # # Paytransactions:
      # # Only a concierge can create a paytransaction
      # can :create, Paytransaction if user.belongs_to_concierge?

    elsif user.role? 'employee' #concierge employee

      ###########
      # Users   
      # Can read, update, and delete their own profile   
      can [:read, :update,:destroy], User, :id => user.id

      # ###########
      # # Experiment: 
      # # User can manage their own experiments
      can :manage, Experiment do |experiment|
        experiment.user_id == current_user.id
      end

    elsif user.role? 'concierge' #concierge employee

      ###########
      # Users   
      # Can read, update, and delete their own profile   
      can [:read, :update,:destroy], User, :id => user.id

    else
      # Can read activities


      # can :create, Comment
      # can :update, Comment do |comment|
      #   comment.try(:user) == user || user.role?(:moderator)
      # end

    end
  end
end