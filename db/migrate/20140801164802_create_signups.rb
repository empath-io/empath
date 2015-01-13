class CreateSignups < ActiveRecord::Migration
  def change
    create_table :signups do |t|
    	t.integer :user_id
    	t.integer :experiment_id
    	t.integer :subject_id
      t.string :client_ip

      t.timestamps
    end
  end
end
