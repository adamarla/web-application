class AddWeightToYardsticks < ActiveRecord::Migration
  def change
    add_column :yardsticks, :weight, :integer, :default => 1
  end
end
