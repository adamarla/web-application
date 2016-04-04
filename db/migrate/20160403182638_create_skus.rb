class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.string :stockable_type
      t.integer :stockable_id 
      t.string :path
    end

    add_index :skus, :stockable_id 
  end
end
