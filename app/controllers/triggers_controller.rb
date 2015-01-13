class TriggersController < ApplicationController
  before_action :set_trigger, only: [:show, :edit, :update, :destroy]
  before_action :set_experiment
  before_action :set_triggers, except: [:create,:update]
  before_action :set_breadcrumb, only:[:index]

  # GET /triggers
  # GET /triggers.json
  def index
    @triggers = @experiment.triggers
  end

  # GET /triggers/1
  # GET /triggers/1.json
  def show
    @show_modal = 'show'
    @experiment= @trigger.experiment
     respond_to do |format|
       format.js
       format.html{}
     end    
  end

  # GET /triggers/new
  def new
    @trigger = Trigger.new
    @trigger.trigger_time_zone = current_user.default_trigger_time_zone
    @trigger.experiment_id = @experiment.id
    @show_modal = 'show'
    @operations = @experiment.operations
     respond_to do |format|
       format.js
       format.html{}
     end    
  end

  # GET /triggers/1/edit
  def edit
    @experiment= @trigger.experiment
    @show_modal = 'show'
    # Remove this trigger's operation from options
    this_operation = @trigger.operation
    @operations = @experiment.operations.to_a
    @operations.delete(this_operation)
     respond_to do |format|
       format.js
       format.html{}
     end    
  end

  # POST /triggers
  # POST /triggers.json
  def create
    # debugger
    trigger_params_mod = trigger_params
    # Set up date variables within params hash
    if trigger_params['date']
      date_array = datepicker_to_array(trigger_params['date'])
      trigger_params_mod['start_month'] = date_array[0]
      trigger_params_mod['start_day'] = date_array[1]
      trigger_params_mod['start_year'] = date_array[2]
      trigger_params_mod.delete('date')
    end
    # update object
    @trigger = Trigger.new(trigger_params_mod)
    respond_to do |format|
      if @trigger.save
        set_triggers
        @show_modal = 'hide'
        format.js
        format.html { redirect_to experiment_triggers_path(@experiment), notice: 'Trigger was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trigger }
      else
        set_triggers
        @show_modal = 'show'
         format.js
        format.html { redirect_to experiment_triggers_path(@experiment) }
        format.json { render json: @trigger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /triggers/1
  # PATCH/PUT /triggers/1.json
  def update
    trigger_params_mod = trigger_params
    # Set up date variables within params hash
    if trigger_params['date']    
      date_array = datepicker_to_array(trigger_params['date'])
      trigger_params_mod['start_month'] = date_array[0]
      trigger_params_mod['start_day'] = date_array[1]
      trigger_params_mod['start_year'] = date_array[2]
      trigger_params_mod.delete('date')
    end
    @experiment= @trigger.experiment
    respond_to do |format|
      if @trigger.update(trigger_params_mod)
        set_triggers
        @show_modal = 'hide'
         format.js
        format.html { redirect_to @trigger, notice: 'Trigger was successfully updated.' }
        format.json { head :no_content }
      else
        # Remove this trigger's operation from options
        this_operation = @trigger.operation
        @operations = @experiment.operations.to_a
        @operations.delete(this_operation)
        set_triggers
        @show_modal = 'show'
         format.js
        format.html { render action: 'edit' }
        format.json { render json: @trigger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /triggers/1
  # DELETE /triggers/1.json
  def destroy
    @experiment= @trigger.experiment
    @trigger.destroy
    set_triggers
    respond_to do |format|
      format.html { redirect_to experiment_triggers_path(@experiment) }
      format.json { head :no_content }
      format.js
    end
  end

  private

    def set_breadcrumb
      @breadcrumb = []
      @breadcrumb << ['Dashboard',experiments_path]
      # @breadcrumb << ["Exp: #{@experiment.name.capitalize}",dashboard_path(@experiment)]
      @breadcrumb << ['Triggers','']
    end  

    # Use callbacks to share common setup or constraints between actions.
    def set_trigger
      @trigger = Trigger.find(params[:id])
    end

    def set_triggers
      if @experiment
        @triggers = @experiment.triggers
      else
        @triggers = Trigger.all
      end
    end

    def set_experiment
      if params[:experiment_id]
        @experiment = Experiment.find(params[:experiment_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trigger_params
      params.require(:trigger).permit(:experiment_id, :hour,:minute,:am,:repeat, :interval, :date,:start_month,:start_day,:start_year,:trigger_time_zone,:preceding_operation_id)
    end
end
