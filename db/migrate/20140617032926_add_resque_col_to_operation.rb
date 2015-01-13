class AddResqueColToOperation < ActiveRecord::Migration
  def change
    add_column :operations, :schedule_name, :string
  end
end
