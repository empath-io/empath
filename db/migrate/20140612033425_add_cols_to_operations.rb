class AddColsToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :executed, :boolean
  end
end
