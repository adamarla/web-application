class CreateJokes < ActiveRecord::Migration
  def change
    create_table :jokes do |t|
      t.string :uid, limit: 15 
      t.boolean :image, default: false
      t.integer :num_jotd 
    end
  end
end
