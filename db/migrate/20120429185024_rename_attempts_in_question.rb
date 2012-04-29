class RenameAttemptsInQuestion < ActiveRecord::Migration
  def change 
    rename_column :questions, :attempts, :n_picked
  end 
end
