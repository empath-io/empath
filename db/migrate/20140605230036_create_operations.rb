class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :name
      t.integer :trigger_id
      t.integer :operationtype_id

      t.timestamps
    end
  end
end
