class AddLastPickedOnToPuzzles < ActiveRecord::Migration
  def up
    change_table :puzzles do |t|
      t.date :last_picked_on
    end
  end 

  def down
    change_table :puzzles do |t|
      t.remove :last_picked_on
    end
  end 
end
