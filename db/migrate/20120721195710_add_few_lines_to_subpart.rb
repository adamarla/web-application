class AddFewLinesToSubpart < ActiveRecord::Migration
  def change
    add_column :subparts, :few_lines, :boolean, :default => false
  end
end
