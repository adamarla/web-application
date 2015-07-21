class RenameKoshishToAttempt < ActiveRecord::Migration
  def change 
    rename_table :attempts, :tryouts 
    rename_table :koshishein, :attempts
  end 
end
