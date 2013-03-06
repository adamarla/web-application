class DropCourses < ActiveRecord::Migration
  def up
    drop_table :courses
  end

  def down
    create_table :courses do |t|
      t.string :name, :limit => 50
      t.integer :board_id
      t.integer :subject_id
      t.integer :klass
      t.boolean :active, :default => true
    end
  end
end
