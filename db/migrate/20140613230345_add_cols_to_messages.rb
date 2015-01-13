class AddColsToMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :sid, :string
    remove_column :messages, :application_sid, :string
    remove_column :messages, :status_callback, :string
    add_column :messages, :status, :string, default:'unqueued'
    add_column :messages, :subject_id, :integer
  end
end
