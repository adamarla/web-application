class AddNumDroppedToUsages < ActiveRecord::Migration
  def change
    add_column :usages, :num_dropped, :integer, default: 0
  end
end
