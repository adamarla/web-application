class AddRubricIdToExams < ActiveRecord::Migration
  def change
    add_column :exams, :rubric_id, :integer
  end
end
