class RemoveTotalFromUsage < ActiveRecord::Migration
  def up
    remove_column :usages, :streak_total
  end

  def down
    add_column :usages, :streak_total, :integer, default: 0
  end
end
