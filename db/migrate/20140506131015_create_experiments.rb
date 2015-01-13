class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end
end
