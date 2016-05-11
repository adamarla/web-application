class TrackChapterInSkills < ActiveRecord::Migration
  def up
    add_column :snippets, :chapter_id, :integer 
    remove_column :snippets, :skill_id 
    add_index :snippets, :chapter_id 
  end

  def down
    remove_column :snippets, :chapter_id 
    add_column :snippets, :skill_id, :integer 
  end
end
