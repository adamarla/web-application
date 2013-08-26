class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.integer :lesson_id
      t.integer :milestone_id
      t.integer :index, default: -1

      t.timestamps
    end
  end
end
