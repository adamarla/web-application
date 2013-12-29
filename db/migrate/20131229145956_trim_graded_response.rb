class TrimGradedResponse < ActiveRecord::Migration
  def up
    rename_column :graded_responses, :system_marks, :marks
    remove_column :graded_responses, :disputed
    remove_column :graded_responses, :closed
    remove_column :graded_responses, :marks_teacher
    remove_column :examiners, :disputed
  end 

  def down
    add_column :examiners, :disputed, :integer, default: 0
    add_column :graded_responses, :marks_teacher, :float
    add_column :graded_responses, :closed, :boolean, default: false
    add_column :graded_responses, :disputed, :boolean, default: false
    rename_column :graded_responses, :marks, :system_marks
  end
end
