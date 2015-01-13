class AddAlertValuesToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :alert_threshold, :string
    add_column :operations, :alert_context, :string # ">","<","=="
  end
end
