class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.boolean :outgoing
      t.string :sid
      t.string :to_number
      t.string :from_number
      t.string :body
      t.string :status_callback
      t.string :application_sid
      t.string :message_sid
      t.string :account_sid

      t.timestamps
    end
  end
end
