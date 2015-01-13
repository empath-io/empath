class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.text :name
      t.text :type
      t.boolean :approved, :default => false

      t.timestamps
    end
  end
end
