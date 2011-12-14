class AddStudyGroupIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :study_group_id, :integer
  end
end
