class RenameCoursePackToAnswerSheet < ActiveRecord::Migration
  def change 
    rename_table :course_packs, :answer_sheets
  end 
end
