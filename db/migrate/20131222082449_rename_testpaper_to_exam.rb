class RenameTestpaperToExam < ActiveRecord::Migration
  def change 
    rename_table :testpapers, :exams
    rename_column :worksheets, :testpaper_id, :exam_id
    rename_column :graded_responses, :testpaper_id, :exam_id
  end 
end
