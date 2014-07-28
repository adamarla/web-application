class CreateHints < ActiveRecord::Migration
  def change
    create_table :hints do |t|
      t.text :text
      t.integer :index
      t.integer :subpart_id
    end
    add_index :hints, :subpart_id
  end
end
