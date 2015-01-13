class ExperimentsController < ApplicationController
  load_and_authorize_resource only: [:show, :edit, :update, :destroy]
  before_action :set_experiment, only: [:show, :edit, :update, :destroy]
  before_filter :require_user
  before_action :set_breadcrumb

  # GET /experiments
  # GET /experiments.json
  def index
    set_experiments 
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @show_modal = 'show'
     respond_to do |format|
        # If not an ajax request, redirect to index
       format.html
     end   
  end

  # GET /experiments/new
  def new
    @experiment = Experiment.new
    @experiment.user = current_user
    @show_modal = 'show'
     respond_to do |format|
       format.js
       format.html{}
     end    
  end

  # GET /experiments/1/edit
  def edit
    @show_modal = 'show'
     respond_to do |format|
           format.html{}
           format.js
     end     
  end

  # POST /experiments
  # POST /experiments.json
  def create
    @experiment = Experiment.new(experiment_params)
    set_experiments
    respond_to do |format|  
      if @experiment.save
        @show_modal = 'hide'
        format.html { redirect_to @experiment, notice: 'Experiment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @experiment }
        format.js
      else
        @show_modal = 'show'
        format.html { render action: 'new' }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /experiments/1
  # PATCH/PUT /experiments/1.json
  def update
    set_experiments
    respond_to do |format|
      if @experiment.update(experiment_params)
        @show_modal = 'hide'
        format.js        
        format.html { redirect_to @experiment, notice: 'Experiment was successfully updated.' }
        format.json { head :no_content }
      else
        @show_modal = 'show'
        format.js
        format.html { render action: 'edit' }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    set_experiments
    @experiment.destroy
    respond_to do |format|
      format.html { redirect_to experiments_url }
      format.json { head :no_content }
    end
  end

  private

    def set_breadcrumb
      @breadcrumb = []
      @breadcrumb << ['Dashboard','']
    end  

    # Set @experiment
    def set_experiment
      @experiment = Experiment.find(params[:id])
    end

    # Set @experiments
    def set_experiments
      # If current_user is an admin
      if current_user.is_god? || current_user.is_admin?
        # debugger
        
        # If user is specified in URL, return user's experiments
        if params[:user_id] && (user = User.find(params[:user_id]))
          if !current_user.member_of?(user.organization) && (current_user.id != user.id)
            @experiments = []
          else
            @experiments = user.experiments # user's experiments
          end       

        # If organization is specified in URL, return all org experiments
        elsif params[:organization_id] && (org = Organization.find(params[:organization_id]))
          if !current_user.member_of?(org)
            @experiments = []
          else
            @experiments = org.experiments # all org's experiments
          end

        # If organization isn't specified, return all current_user's experiments (if admin) or all experiments (if god)
        elsif current_user.is_god?
          @experiments = Experiment.all  
        elsif current_user.is_admin?
          @experiments = current_user.experiments      
        else
          @experiments = []
        end

      # If current_user isn't an admin
      else
        @experiments = current_user.experiments
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def experiment_params
      params.require(:experiment).permit(:name, :user_id,:custom_field_1_name,:custom_field_2_name,:custom_field_3_name)
    end
end
