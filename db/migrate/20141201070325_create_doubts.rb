class CreateDoubts < ActiveRecord::Migration
  def change
    create_table :doubts do |t|
      t.integer :student_id 
      t.integer :examiner_id
      t.string :scan, limit: 30 
      t.string :solution, limit: 30
      t.string :tags
      t.timestamps
    end
    add_index :doubts, :examiner_id 
    add_index :doubts, :student_id 
  end
end
