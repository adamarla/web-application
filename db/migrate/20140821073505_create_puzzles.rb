class CreatePuzzles < ActiveRecord::Migration
  def change
    create_table :puzzles do |t|
      t.text :text
      t.integer :question_id
      t.integer :version, default: 0
      t.integer :n_picked, default: 0
      t.boolean :active, default: false
      t.timestamps
    end
    add_index :puzzles, :question_id
  end
end
