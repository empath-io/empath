class OperationsController < ApplicationController
  before_action :set_operation, only: [:show, :edit, :update, :destroy]
  before_action :set_trigger, except: [:destroy]
  before_action :set_operations, except: [:create,:update,:destroy]
  before_action :set_breadcrumb, only: [:index]
    # GET /operations
  # GET /operations.json
  def index
  end

  # GET /operations/1
  # GET /operations/1.json
  def show
    debugger
    @trigger = @operation.trigger
    @show_modal = 'show'
    respond_to do |format|
      format.js
      format.html
    end    
  end

  # GET /operations/new
  def new
    @operation = Operation.new
    @operation.trigger = @trigger
    @show_modal = 'show'
    respond_to do |format|
      format.js
      format.html
    end 
  end

  # GET /operations/1/edit
  def edit
    @trigger = @operation.trigger
    @show_modal = 'show'
    respond_to do |format|
      format.js
      format.html
    end 
  end

  # POST /operations
  # POST /operations.json
  # Uses Resqueu to queue up Twilio API calls to generate SMS messages
  def create
    @operation = Operation.new(operation_params)
    respond_to do |format|
      if @operation.save
        debugger
        # Schedule job for operation
        @operation.update_schedule
        set_operations
        @show_modal = 'hide'
        format.html { redirect_to @operation, notice: 'Operation was successfully queued.' }
        format.json { render action: 'show', status: :created, location: @operation }
        format.js
      else
        debugger
        @show_modal = 'show'
        format.html { render action: 'new' }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /operations/1
  # PATCH/PUT /operations/1.json
  def update
    respond_to do |format|
      if @operation.update(operation_params)
        @show_modal = 'hide'
        format.html { redirect_to @operation, notice: 'Operation was successfully updated.' }
        format.json { head :no_content }
        set_operations
        format.js
      else
        @show_modal = 'show'
        format.html { render action: 'edit' }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /operations/1
  # DELETE /operations/1.json
  def destroy
    set_trigger
    @operation.destroy
    set_operations
    respond_to do |format|
      format.html { redirect_to operations_url }
      format.json { head :no_content }
      format.js
    end
  end

  private

    def set_breadcrumb
      experiment = @trigger.experiment
      @breadcrumb = []
      @breadcrumb << ['Dashboard',experiments_path]
      # @breadcrumb << ["Exp: #{experiment.name.capitalize}",dashboard_path(experiment)]
      @breadcrumb << ['Triggers',experiment_triggers_path(experiment)]
      @breadcrumb << ['Operations','']
    end  

    # Use callbacks to share common setup or constraints between actions.
    def set_operation
      @operation = Operation.find(params[:id])
    end

    def set_operations
      if @trigger && @trigger.operation
        @operations = [@trigger.operation]
      else
        @operations = []
      end
    end

    def set_trigger
      if params[:trigger_id]
        @trigger = Trigger.find(params[:trigger_id])
      else
        @trigger = @operation.trigger
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operation_params
      params.require(:operation).permit(:name, :trigger_id,:content,:kind, :operationtype_id,:alert_threshold,:alert_context)
    end
end
