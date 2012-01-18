class RenameStudyGroupFk < ActiveRecord::Migration
  def change 
    rename_column :faculty_rosters, :study_group_id, :sektion_id
    rename_column :students, :study_group_id, :sektion_id
  end 
end
