class AddMeaningToYardstick < ActiveRecord::Migration
  def change
    add_column :yardsticks, :meaning, :string
    rename_column :yardsticks, :description, :example
  end
end
