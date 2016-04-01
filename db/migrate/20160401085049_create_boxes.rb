class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.string :uid, limit: 15 
      t.integer :chapter_id 
      t.integer :language_id 
      t.integer :min_difficulty 
      t.integer :max_difficulty
      t.boolean :of_questions, default: false 
      t.boolean :of_skills, default: false 
      t.boolean :of_snippets, default: false 
      t.timestamps
    end
  end
end
