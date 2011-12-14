class RenameGradeDescFkInGrade < ActiveRecord::Migration
  def change 
    rename_column :grades, :grade_description_id, :yardstick_id
  end 
end
