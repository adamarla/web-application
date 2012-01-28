class CreateTestpapers < ActiveRecord::Migration
  def change
    create_table :testpapers do |t|
      t.integer :quiz_id
      t.string :name

      t.timestamps
    end
  end
end
