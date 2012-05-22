class AddIndexToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :index, :integer, :default => -1
  end
end
