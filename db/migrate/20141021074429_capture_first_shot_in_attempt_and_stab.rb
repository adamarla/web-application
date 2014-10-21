class CaptureFirstShotInAttemptAndStab < ActiveRecord::Migration
  def change 
    add_column :stabs, :first_shot, :integer 
    add_column :attempts, :first_shot, :integer 
  end 
end
