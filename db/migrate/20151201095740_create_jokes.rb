class CreateJokes < ActiveRecord::Migration
  def change
    create_table :jokes do |t|
      t.string :uid, limit: 20 
      t.boolean :image, default: false
      t.integer :num_shown, default: 0
      t.boolean :disabled, default: false 
    end
  end
end
