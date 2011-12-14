class AddMcqToGradeDescription < ActiveRecord::Migration
  def change
    add_column :grade_descriptions, :mcq, :boolean, :default => false
  end
end
