class CreateInventory < ActiveRecord::Migration
  def change
    create_table :inventory do |t|
      t.integer :zip_id 
      t.integer :sku_id 
    end

    add_index :inventory, :sku_id 
    add_index :inventory, :zip_id
  end
end
