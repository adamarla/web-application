class AddExaminerIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :examiner_id, :integer
  end
end
