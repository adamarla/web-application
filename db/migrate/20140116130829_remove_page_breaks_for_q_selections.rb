class RemovePageBreaksForQSelections < ActiveRecord::Migration
  def up
    remove_column :q_selections, :page_breaks
  end

  def down
    add_column :q_selections, :page_breaks, :string, limit: 10
    # Not going to re-populate the column here. Will take too long. 
    # If this migration has to be reversed, then add a method 
    # to QSelection which will evaluate the needed string on demand
  end
end
