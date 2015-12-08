class RemoveTimeInActivityFromAttempts < ActiveRecord::Migration
  def up
    remove_column :attempts, :time_in_activity 
  end

  def down
    add_column :attempts, :time_in_activity, :integer
  end
end
