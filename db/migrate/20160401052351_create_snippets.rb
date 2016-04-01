class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.integer :examiner_id
      t.integer :skill_id
      t.integer :num_attempted, default: 0
      t.integer :num_correct, default: 0
    end

    add_index :snippets, :examiner_id 
    add_index :snippets, :skill_id
  end
end
