class AddNumViewsToWorksheets < ActiveRecord::Migration
  def change
    add_column :worksheets, :num_views_student, :integer, default: 0
    add_column :worksheets, :num_views_teacher, :integer, default: 0
  end
end
