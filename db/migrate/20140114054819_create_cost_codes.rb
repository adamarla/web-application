class CreateCostCodes < ActiveRecord::Migration
  def change
    create_table :cost_codes do |t|
      t.text :description
      t.boolean :subscription

      t.timestamps
    end
  end
end
