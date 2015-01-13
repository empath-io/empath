class ChangeOperationContentColtype < ActiveRecord::Migration
	def up
	    change_column :operations, :content, :text
	end
	def down
	    # This might cause trouble if you have strings longer
	    # than 255 characters.
	    change_column :operations, :content, :string
	end
end
