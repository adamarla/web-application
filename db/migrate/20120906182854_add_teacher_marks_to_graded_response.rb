class AddTeacherMarksToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :marks_teacher, :integer
  end
end
