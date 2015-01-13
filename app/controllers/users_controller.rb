class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :set_organization
  before_filter :require_user # User must be logged in to see any of these actions

  before_filter :require_organization_admin_user, only: [:destroy,:new, :create]

  load_and_authorize_resource # Loads User resources according to Ability.rb

  # GET /users
  # GET /users.json
  def index
    @new_user = User.new
    set_users
    @show_modal = 'hide'
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @show_modal = 'show'
    respond_to do |format|
      format.html{}
      format.js
    end 
  end

  # GET /users/new
  def new
    @user = User.new
    if @organization
      @user.organization_id = @organization.id
      @user.default_trigger_time_zone = @organization.default_trigger_time_zone
    elsif current_user.is_admin? && current_user.organization_id
      @user.organization_id = current_user.organization_id
    end
    @show_modal = 'show'
    respond_to do |format|
      format.html{}
      format.js
    end       
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @show_modal = 'show'
    respond_to do |format|
      format.html{}
      format.js{}
    end    
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    # if params[:desk_id]
    #   @desk = Desk.find(params[:desk_id])
    # elsif params[:organization_id]
    #   @organization = Organization.find(params[:organization_id])
    # end
    respond_to do |format|
      if @user.save
        @show_modal = 'hide'
        set_users
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.js 
        format.json { render action: 'show', status: :created, location: @user }
      else
        debugger
        @new_user = @user
        set_users
        @show_modal = 'show'
        format.js
        format.html { render action: 'index' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    debugger
    respond_to do |format|
      if @user.update(user_params)
        @show_modal = 'hide'
        set_users
        format.js
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        @show_modal = 'show'
        format.js
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    debugger
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone_number,:login, :email, :password,:password_confirmation, :role,:organization_id,:default_trigger_time_zone)
    end

    def set_organization
      if params[:organization_id]
        @organization = Organization.find(params[:organization_id])
      elsif params[:user] && !params[:user][:organization_id].empty? # in the case of a submitted form where user is created under org
        @organization = Organization.find(params[:user][:organization_id])
      else
        @organization_id = nil
      end
    end    

    def set_users
      if @organization
        @users = get_permitted_users(@organization)
      else
        @users = get_permitted_users(current_user)
      end
    end      

    def get_permitted_users(obj)
      # If current_user is an admin
      if current_user.is_god? || current_user.is_admin?
        # debugger
        
        # If organization is specified in URL, return all org employees
        if obj.class == Organization
          if !current_user.member_of?(obj)
            return []
          else
            return obj.users # All org's users
          end

        # If organization isn't specified, return all user's organization employees (if admin) or all users (if god)
        elsif current_user.is_god?
          return User.all        
        elsif (obj == current_user) && !current_user.organization.nil?
          return current_user.organization.users
        else
          return [current_user]
        end

      # If current_user isn't an admin
      else
        return [current_user]
      end
    end





end
