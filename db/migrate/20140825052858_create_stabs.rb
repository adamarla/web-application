class CreateStabs < ActiveRecord::Migration
  def change
    create_table :stabs do |t|
      t.integer :student_id
      t.integer :examiner_id
      t.integer :question_id
      t.integer :puzzle_id
      t.integer :strength, default: -1 
      t.string :scan, limit: 40
      t.timestamps
    end

    add_index :stabs, :examiner_id 
    add_index :stabs, :student_id 
    add_index :stabs, :puzzle_id 
    add_index :stabs, :question_id
  end
end
