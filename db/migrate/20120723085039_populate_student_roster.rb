class PopulateStudentRoster < ActiveRecord::Migration
  def up
    Sektion.build_student_roster
  end

  def down
    Sektion.unbuild_student_roster
  end
end
