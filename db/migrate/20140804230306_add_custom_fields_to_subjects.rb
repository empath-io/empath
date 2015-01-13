class AddCustomFieldsToSubjects < ActiveRecord::Migration
  def change
    add_column :experiments, :custom_field_1_name, :string
    add_column :experiments, :custom_field_2_name, :string
    add_column :experiments, :custom_field_3_name, :string
    add_column :subjects, :custom_field_1_value, :string
    add_column :subjects, :custom_field_2_value, :string
    add_column :subjects, :custom_field_3_value, :string
  end
end
