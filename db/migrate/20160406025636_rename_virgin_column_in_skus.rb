class RenameVirginColumnInSkus < ActiveRecord::Migration
  def up 
    rename_column :skus, :virgin, :has_svgs
    change_column_default :skus, :has_svgs, false 
  end 

  def down 
    rename_column :skus, :has_svgs, :virgin 
    change_column_default :skus, :virgin, true
  end 
end
