class DropYardstick < ActiveRecord::Migration
  def up
    drop_table :yardsticks
  end

  def down
    # irreversible migration
  end
end
