class RenameOffsetColumnInSubpart < ActiveRecord::Migration
  def change 
    rename_column :subparts, :offset, :relative_page
  end
end
