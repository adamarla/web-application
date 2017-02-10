class MoveSvgsOutOfSkus < ActiveRecord::Migration
  def up
    remove_column :skus, :has_svgs 
    add_column :riddles, :has_svgs, :boolean, default: false 
    add_column :skills, :has_svgs, :boolean, default: false 
  end

  def down
    remove_column :skills, :has_svgs
    remove_column :riddles, :has_svgs
    add_column :skus, :has_svgs, :boolean, default: false 
  end
end
