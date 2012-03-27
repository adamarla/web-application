class AddMarksToCoursePack < ActiveRecord::Migration
  def change
    add_column :course_packs, :marks, :integer, :default => nil
  end
end
