class AddGradedToCoursePack < ActiveRecord::Migration
  def change
    add_column :course_packs, :graded, :boolean, :default => false
  end
end
