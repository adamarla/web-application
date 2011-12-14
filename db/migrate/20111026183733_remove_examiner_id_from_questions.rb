class RemoveExaminerIdFromQuestions < ActiveRecord::Migration
  def up
    remove_column :questions, :examiner_id
  end

  def down
    add_column :questions, :examiner_id, :integer
  end
end
