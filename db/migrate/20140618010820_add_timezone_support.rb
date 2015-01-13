class AddTimezoneSupport < ActiveRecord::Migration
  def change
    add_column :users, :default_trigger_time_zone, :string  	
    add_column :triggers, :trigger_time_zone, :string
  end
end
