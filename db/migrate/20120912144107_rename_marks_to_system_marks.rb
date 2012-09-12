class RenameMarksToSystemMarks < ActiveRecord::Migration
  def change 
    rename_column :graded_responses, :marks, :system_marks
  end
end
