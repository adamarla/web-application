class ChangeTeacherMarksToFloat < ActiveRecord::Migration
  def up
    change_column :graded_responses, :marks_teacher, :float
  end

  def down
    change_column :graded_responses, :marks_teacher, :integer
  end
end
