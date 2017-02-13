class DropProblemAndFragment < ActiveRecord::Migration
  def up
    drop_table :problems 
    drop_table :fragments 
  end

  def down
    english = Language.named 'english' 
    medium = Difficulty.named 'medium'

    create_table :problems do |t| 
      t.integer :chapter_id 
      t.integer :language_id, default: english 
      t.integer :difficulty, default: medium 
      t.integer :examiner_id 
    end 

    create_table :fragments do |t| 
      t.integer :chapter_id
      t.integer :language_id, default: english 
      t.integer :examiner_id 
      t.integer :num_attempted, default: 0
      t.integer :num_correct, default: 0
    end 
  end
end
