class RenameGradeDescToYardstick < ActiveRecord::Migration
  def change 
    rename_table :grade_descriptions, :yardsticks 
  end 
end
