class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :title, limit: 150 
      t.text :description 
      t.integer :teacher_id
      t.timestamps
    end
    add_index :lessons, :teacher_id
  end
end
