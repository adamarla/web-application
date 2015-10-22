class AddNumSurrenderToAttempt < ActiveRecord::Migration
  def change
    add_column :attempts, :num_surrender, :integer 
  end
end
