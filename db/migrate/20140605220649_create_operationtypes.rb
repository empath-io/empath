class CreateOperationtypes < ActiveRecord::Migration
  def change
    create_table :operationtypes do |t|
      t.string :name
      t.string :type
      t.text :content

      t.timestamps
    end
  end
end
