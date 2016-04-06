class AddUidToChapterAndSkills < ActiveRecord::Migration
  def change
    add_column :chapters, :uid, :string, limit: 10 
    add_column :skills, :uid, :string, limit: 15
  end
end
