class RenameStartEndColumnsInQSel < ActiveRecord::Migration
  def change 
    rename_column :q_selections, :start, :start_page
    rename_column :q_selections, :end, :end_page
  end
end
