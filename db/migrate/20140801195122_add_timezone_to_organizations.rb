class AddTimezoneToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :default_trigger_time_zone, :string
  end
end
