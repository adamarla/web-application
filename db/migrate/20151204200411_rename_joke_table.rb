class RenameJokeTable < ActiveRecord::Migration
  def change 
    rename_table :jokes, :analgesics 
  end 
end
