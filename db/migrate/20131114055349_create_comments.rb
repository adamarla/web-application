class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :x
      t.integer :y
      t.text :tex
      t.integer :graded_response_id

      t.timestamps
    end
  end
end
