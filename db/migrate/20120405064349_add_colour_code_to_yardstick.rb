class AddColourCodeToYardstick < ActiveRecord::Migration
  def change
    add_column :yardsticks, :colour, :integer, :default => nil
  end
end
