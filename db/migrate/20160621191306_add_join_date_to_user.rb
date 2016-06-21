class AddJoinDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :join_date, :date    
  end
end
