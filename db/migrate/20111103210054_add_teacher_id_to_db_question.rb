class AddTeacherIdToDbQuestion < ActiveRecord::Migration
  def change
    add_column :db_questions, :teacher_id, :integer
  end
end
