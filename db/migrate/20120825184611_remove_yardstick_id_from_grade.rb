class RemoveYardstickIdFromGrade < ActiveRecord::Migration
  def up
    remove_column :grades, :yardstick_id
  end

  def down
    add_column :grades, :yardstick_id, :integer
  end
end
