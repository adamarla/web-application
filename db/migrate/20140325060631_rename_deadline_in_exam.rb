class RenameDeadlineInExam < ActiveRecord::Migration
  def change 
    rename_column :exams, :deadline, :grade_by
  end 
end
