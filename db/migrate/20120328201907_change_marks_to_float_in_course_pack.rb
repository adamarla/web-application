class ChangeMarksToFloatInCoursePack < ActiveRecord::Migration
  def up
    change_table :course_packs do |t|
      t.change :marks, :float
    end
  end

  def down
    change_table :course_packs do |t|
      t.change :marks, :integer
    end
  end
end
