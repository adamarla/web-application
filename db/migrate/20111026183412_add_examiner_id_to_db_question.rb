class AddExaminerIdToDbQuestion < ActiveRecord::Migration
  def change
    add_column :db_questions, :examiner_id, :integer
  end
end
