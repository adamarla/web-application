class RenameLevelToGrade < ActiveRecord::Migration
  def change 
    rename_table :levels, :grades
    rename_column :chapters, :level_id, :grade_id
  end 
end
