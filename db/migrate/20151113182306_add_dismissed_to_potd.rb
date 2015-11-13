class AddDismissedToPotd < ActiveRecord::Migration
  def change
    add_column :potd, :num_dismissed, :integer, default: 0
  end
end
