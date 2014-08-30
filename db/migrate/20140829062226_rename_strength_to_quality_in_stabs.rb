class RenameStrengthToQualityInStabs < ActiveRecord::Migration
  def change 
    rename_column :stabs, :strength, :quality
  end 
end
