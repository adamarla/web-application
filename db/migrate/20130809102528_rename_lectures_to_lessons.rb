class RenameLecturesToLessons < ActiveRecord::Migration
  def up
    rename_table :lectures, :lessons
  end

  def down
    rename_table :lessons, :lectures 
  end
end
