class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title, limit: 150
      t.text :description
      t.integer :teacher_id
      t.timestamps
    end
    add_index :courses, :teacher_id
  end
end
