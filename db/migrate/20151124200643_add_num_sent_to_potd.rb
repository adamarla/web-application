class AddNumSentToPotd < ActiveRecord::Migration
  def change
    add_column :potd, :num_sent, :integer, default: 0
  end
end
