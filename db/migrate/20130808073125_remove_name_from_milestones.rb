class RemoveNameFromMilestones < ActiveRecord::Migration
  def up
    remove_column :milestones, :name
  end

  def down
    add_column :milestones, :name, :string, limit: 70
  end
end
