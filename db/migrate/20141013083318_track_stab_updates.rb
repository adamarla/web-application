class TrackStabUpdates < ActiveRecord::Migration
  def change 
    add_column :stabs, :cracked_it, :boolean 
    add_column :stabs, :answer_deduct, :integer, default: 0 
    add_column :stabs, :solution_deduct, :integer, default: 0 
    add_column :stabs, :proofread_credit, :integer, default: 0 
  end 
end
