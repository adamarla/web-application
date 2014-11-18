class GreditFlavours < ActiveRecord::Migration
  def change 
    rename_column :students, :gredits, :reward_gredits 
    add_column :students, :paid_gredits, :integer, default: 0
  end 
end
