class ReplacePuzzleIdWithBooleanInStabs < ActiveRecord::Migration
  def up
    remove_column :stabs, :puzzle_id
    add_column :stabs, :puzzle, :boolean, default: true 
  end

  def down
    remove_column :stabs, :puzzle 
    add_column :stabs, :puzzle_id, :integer 
  end
end
