class RenameUidToNameInBoxes < ActiveRecord::Migration
  def change 
    rename_column :boxes, :uid, :name
  end 
end
