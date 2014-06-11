class AddRubricIdToTeacherAndExam < ActiveRecord::Migration
  def change
    add_column :teachers, :rubric_id, :integer
    add_column :exams, :rubric_id, :integer
  end
end
