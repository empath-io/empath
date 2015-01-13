class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.integer :experiment_id
      t.integer :start_month
      t.integer :start_day
      t.integer :start_year
      t.integer :hour, default:0
      t.integer :minute, default:0
      t.boolean :am, default:true
      t.string  :repeat, default: 'none'
      t.integer :interval, default:0 # in minutes

      t.timestamps
    end
  end
end
