class AddKindColToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :kind, :string
    add_column :operations, :content, :string
    remove_column :operations, :operationtype_id, :integer
  end
end
