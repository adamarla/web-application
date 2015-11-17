class AddNumFailedToPotd < ActiveRecord::Migration
  def change
    add_column :potd, :num_failed, :integer, default: 0
  end
end
