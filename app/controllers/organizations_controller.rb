class OrganizationsController < ApplicationController
  load_and_authorize_resource only: [:show, :edit, :update, :destroy]
  before_action :set_organization, only: [:show, :edit, :update, :destroy]
  before_filter :get_type
  before_filter :require_god_user, except: [:show,:edit,:update]
  before_filter :require_admin_user, only: [:show, :edit,:update]

  # GET /organizations
  # GET /organizations.json
  def index
    # @organizations = Organization.all
    @organizations = @klass.scoped
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    @organization = @klass.find(params[:id])
    @show_modal = 'show'
     respond_to do |format|
          # If not an ajax request, redirect to index
           format.html{ redirect_to organizations_path}
           # If ajax request, display modal window 
           format.js
     end      
  end

  # GET /organizations/new
  def new
    @organization = @klass.new
    @show_modal = 'show'
     respond_to do |format|
       format.js
       format.html{}
     end        

  end

  # GET /organizations/1/edit
  def edit
    @organization = @klass.find(params[:id])
    @show_modal = 'show'
     respond_to do |format|
           format.html{}
           format.js
     end      
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = @klass.new(organization_params)

    respond_to do |format|
      if @organization.save
        @show_modal = 'hide'
        @organizations = @klass.scoped
        format.js
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render action: 'show', status: :created, location: @organization }
      else
        @show_modal = 'show'
        format.js
        format.html { render action: 'new' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    @organization = @klass.find(params[:id])
    respond_to do |format|
      if @organization.update(organization_params)
        @show_modal = 'hide'
        @organizations = @klass.scoped
        format.js
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        @show_modal = 'show'
        format.js
        format.html { render action: 'edit' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization = @klass.find(params[:id])
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
      @new_user_link = new_organization_user_path(@organization)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name,:approved,:default_trigger_time_zone)
    end

    # Get type parameter
    def get_type
      resource = request.path.split('/')[1]
      # debugger
      @klass   = Object.const_get(resource.singularize.capitalize)     
    end    
end
