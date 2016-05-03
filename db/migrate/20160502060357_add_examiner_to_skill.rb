class AddExaminerToSkill < ActiveRecord::Migration
  def change
    add_column :skills, :examiner_id, :integer
  end
end
