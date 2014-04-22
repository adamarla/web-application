class CreateFreebies < ActiveRecord::Migration
  def change
    create_table :freebies do |t|
      t.integer :course_id
      t.integer :lesson_id
      t.integer :index, default: 0
      t.timestamps
    end
    add_index :freebies, :course_id
    add_index :freebies, :lesson_id
  end
end
