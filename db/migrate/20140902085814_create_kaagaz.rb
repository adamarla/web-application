class CreateKaagaz < ActiveRecord::Migration
  def change
    create_table :kaagaz do |t|
      t.string :path, limit: 40 
      t.integer :stab_id 
    end
    add_index :kaagaz, :stab_id
  end
end
