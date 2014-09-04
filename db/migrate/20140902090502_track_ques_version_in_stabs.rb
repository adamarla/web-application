class TrackQuesVersionInStabs < ActiveRecord::Migration
  def up
    change_table :stabs do |t|
      t.integer :question_id 
      t.integer :version
      t.remove :subpart_id 
      t.remove :scan
    end 
    add_index :stabs, :question_id 
  end

  def down
    change_table :stabs do |t|
      t.integer :subpart_id 
      t.string :scan, limit: 40 
      t.remove :question_id  
      t.remove :version
    end 
  end
end
