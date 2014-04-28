class AddDoodleIdToRemark < ActiveRecord::Migration
  def change
    add_column :remarks, :doodle_id, :integer
  end
end
