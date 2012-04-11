class AddOffsetInfoToSubpart < ActiveRecord::Migration
  def change
    add_column :subparts, :relative_index, :integer
    add_column :subparts, :relative_pg, :integer
  end
end
