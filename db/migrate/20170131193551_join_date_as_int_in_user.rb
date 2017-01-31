class JoinDateAsIntInUser < ActiveRecord::Migration
  def up
    remove_column :users, :join_date 
    add_column :users, :join_date, :integer 
  end

  def down
    remove_column :users, :join_date 
    add_column :users, :join_date, :date 
  end
end
