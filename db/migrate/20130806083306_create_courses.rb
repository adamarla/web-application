class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, limit: 50
      t.integer :teacher_id

      t.timestamps
    end
  end
end
