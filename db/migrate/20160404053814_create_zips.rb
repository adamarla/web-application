class CreateZips < ActiveRecord::Migration
  def change
    create_table :zips do |t|
      t.string :name, limit: 25
      t.integer :parcel_id
      t.integer :max_size, default: -1
      t.boolean :open, default: true 
      t.string :shasum, limit: 10
    end

    add_index :zips, :parcel_id 
  end
end
