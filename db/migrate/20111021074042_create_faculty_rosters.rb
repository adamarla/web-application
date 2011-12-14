class CreateFacultyRosters < ActiveRecord::Migration
  def change
    create_table :faculty_rosters do |t|
      t.integer :study_group_id
      t.integer :teacher_id

      t.timestamps
    end
  end
end
