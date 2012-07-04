class RenameTeacherIdInQuestions < ActiveRecord::Migration
  def change 
    rename_column :questions, :teacher_id, :suggestion_id
  end 
end
