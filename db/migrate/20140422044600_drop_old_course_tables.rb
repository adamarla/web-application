class DropOldCourseTables < ActiveRecord::Migration
  def up
    drop_table :courses
    drop_table :coursework
    drop_table :milestones
    drop_table :lectures 
    drop_table :lessons
    drop_table :progressions
  end

  def down
  end
end
