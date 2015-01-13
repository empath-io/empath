class AddSendAsResponseColsToTriggers < ActiveRecord::Migration
  def change
    add_column :triggers, :preceding_operation_id, :integer
  end
end
