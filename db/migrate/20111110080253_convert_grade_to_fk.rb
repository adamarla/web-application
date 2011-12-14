class ConvertGradeToFk < ActiveRecord::Migration
  def change 
    rename_column :graded_responses, :grade, :grade_id
  end 
end
