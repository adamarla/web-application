class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.integer :school_id
      t.date :start_date
      t.integer :duration
      t.integer :bill_cycle
      t.integer :start_day_of_month
      t.references :school
      t.integer :rate_code_id

      t.timestamps
    end
    add_index :contracts, :school_id
  end
end
