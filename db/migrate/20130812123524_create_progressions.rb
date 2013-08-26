class CreateProgressions < ActiveRecord::Migration
  def change
    create_table :progressions do |t|
      t.integer :student_id, index: true
      t.integer :milestone_id, index: true

      t.timestamps
    end
  end
end
