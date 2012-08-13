class RemoveCoursePacks < ActiveRecord::Migration
  def up
    drop_table :course_packs
  end

  def down
    create_table "course_packs", :force => true do |t|
      t.integer  "student_id"
      t.integer  "testpaper_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
