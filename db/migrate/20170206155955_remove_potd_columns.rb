class RemovePotdColumns < ActiveRecord::Migration
  def up
    remove_column :questions, :potd 
    remove_column :questions, :num_potd 
    remove_column :questions, :live 
    
  end

  def down
    add_column :questions, :live, :boolean, default: false 
    add_column :questions, :potd, :boolean, default: false 
    add_column :questions, :num_potd, :integer, default: 0
  end
end
