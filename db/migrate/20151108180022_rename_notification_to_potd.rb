class RenameNotificationToPotd < ActiveRecord::Migration
  def change 
    rename_table :notifications, :potd 
  end 
end
