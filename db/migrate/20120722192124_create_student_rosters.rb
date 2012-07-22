class CreateStudentRosters < ActiveRecord::Migration
  def change
    create_table :student_rosters do |t|
      t.integer :student_id
      t.integer :sektion_id
    end
  end
end
