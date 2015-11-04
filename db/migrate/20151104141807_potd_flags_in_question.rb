class PotdFlagsInQuestion < ActiveRecord::Migration
  def change 
    add_column :questions, :potd, :boolean, default: false 
    add_column :questions, :num_potd, :integer, default: 0
  end 
end
