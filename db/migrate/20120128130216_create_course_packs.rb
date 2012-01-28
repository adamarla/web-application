class CreateCoursePacks < ActiveRecord::Migration
  def change
    create_table :course_packs do |t|
      t.integer :student_id
      t.integer :testpaper_id

      t.timestamps
    end
  end
end
