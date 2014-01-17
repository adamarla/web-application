class CreateRateCodes < ActiveRecord::Migration
  def change
    create_table :rate_codes do |t|
      t.integer :cost_code_id
      t.integer :value
      t.string :currency, :limit => 3

      t.timestamps
    end
  end
end
