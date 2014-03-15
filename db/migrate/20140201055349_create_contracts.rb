class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.integer :customer_id
      t.date :start_date
      t.integer :duration
      t.integer :bill_cycle
      t.integer :bill_day_of_month
      t.integer :rate_code_id
      t.integer :num_students
      t.integer :subject_id
      t.string :title, :limit => 30

      t.timestamps
    end
    add_index :contracts, :customer_id
  end
end
