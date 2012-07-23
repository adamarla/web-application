class RemoveSektionIdFromStudent < ActiveRecord::Migration
  def up
    remove_column :students, :sektion_id
  end

  def down
    add_column :students, :sektion_id, :integer
  end
end
