class SubjectsController < ApplicationController
  before_filter :require_employee_user_or_above
  before_action :set_subject, only: [:show, :edit, :update, :destroy]
  before_action :set_subjects, except: [:create,:update,:destroy]
  before_action :set_experiment, except: [:create,:update]
  before_action :set_signup, only: [:create]
  before_action :set_breadcrumb, only: [:index]

  skip_before_filter :require_employee_user_or_above, only: [:new,:create]
  # These use basic auth for access to the signup page (instead of a user session)
  skip_before_filter :require_user, only: [:new], :if => proc {|c| request.format.html?}
  before_filter :authenticate, only: [:new]

  # GET /subjects
  # GET /subjects.json
  def index
    @show_modal = 'hide'
    set_subjects
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show   
  end

  # GET /subjects/new
  def new
    if params[:desktop].to_i == 1
      @remote_submit = false
    else
      @remote_submit = true
    end
    @show_modal = 'show'
    @subject = Subject.new
    if @experiment
      @subject.experiment_id = @experiment.id
      if current_user
        signups = current_user.signups.where(experiment_id:@experiment.id)
        @signups_today = signups.today
        @signups_yesterday = signups.yesterday 
        @signups_this_week = signups.this_week
      end
    end
    respond_to do |format|
       format.js
       format.html{
          if current_user && current_user.is_concierge?
            render 'new_as_concierge', layout: 'pilot_signup'
          else
            render layout: 'pilot_signup'
          end
        }
    end   
  end

  # GET /subjects/1/edit
  def edit
    @show_modal = 'show'
    respond_to do |format|
       format.js
       format.html{}
    end   
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(subject_params)
    @experiment = @subject.experiment
    respond_to do |format|
      if @subject.valid? && @subject.save

        # Create signup object
        signup = Signup.new(subject_id:@subject.id, experiment_id:@experiment.id,user_id:current_user.id)
        signup.client_ip = ip
        if !signup.save
          Rails.logger.error "Within SubjectsController#create\n\tUnable to save Signup object:\n\t#{signup.inspect}"
        end 

        set_subjects
        @show_modal = 'hide'
        format.js
        format.html { redirect_to concierge_subject_signup_path(@experiment) }
        format.json { render action: 'show', status: :created, location: @subject }
      else
        debugger
        set_subjects
        @show_modal = 'show'
        format.js
        format.html { redirect_to concierge_subject_signup_path(@experiment) }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subjects/1
  # PATCH/PUT /subjects/1.json
  def update
    @experiment = @subject.experiment
    respond_to do |format|
      if @subject.update(subject_params)
        set_subjects
        @show_modal = 'hide'
        format.js
        format.html { redirect_to @subject, notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        set_subjects
        @show_modal = 'show'
        format.js
        format.html { render action: 'edit' }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @experiment = @subject.experiment
    @subject.destroy
    set_subjects
    respond_to do |format|
      format.html { redirect_to experiment_subjects_path(@experiment) }
      format.json { head :no_content }
      format.js
    end
  end

  private

    def set_breadcrumb
      @breadcrumb = []
      @breadcrumb << ['Dashboard',experiments_path]
      # @breadcrumb << ["Exp: #{@experiment.name.capitalize}",dashboard_path(@experiment)]
      @breadcrumb << ['Subjects','']
    end  

    def set_signup
      if params['signup']
        @signup = 1
      else
        @signup = 0
      end
    end

    def set_subjects
      if @experiment
        @subjects = Subject.where(:experiment_id => @experiment.id).order(created_at: :desc)
      else
        @subjects = []
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    def set_experiment
      if params[:experiment_id]
        @experiment = Experiment.find(params[:experiment_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subject_params
      params.require(:subject).permit(:experiment_id, :email, :phone_number,:name,:custom_field_1_value,:custom_field_2_value,:custom_field_3_value)
    end

    def authenticate
      # Authenticate if request is for HTML and there is no logged in user
      if request.format == 'text/html' && current_user.nil?
        authenticate_or_request_with_http_basic('Administration') do |username, password|
          username == ENV['SUBJECT_SIGNUP_LOGIN'] && password == ENV['SUBJECT_SIGNUP_PASSWORD']
        end
      end
    end

end
