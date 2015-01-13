class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.integer :experiment_id
      t.string :email
      t.string :phone_number
      t.string :name

      t.timestamps
    end
  end
end
