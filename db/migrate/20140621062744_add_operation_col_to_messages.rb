class AddOperationColToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :operation_id, :integer
    add_column :messages, :replied, :boolean, :default => false
    add_column :messages, :active, :boolean, :default => true
  end
end
