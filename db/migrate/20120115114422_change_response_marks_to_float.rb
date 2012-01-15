class ChangeResponseMarksToFloat < ActiveRecord::Migration
  def up
    change_table :graded_responses do |t|
      t.change :marks, :float
    end
  end

  def down
    change_table :graded_responses do |t|
      t.change :marks, :integer
    end
  end
end
