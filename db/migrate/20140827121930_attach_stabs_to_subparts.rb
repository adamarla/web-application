class AttachStabsToSubparts < ActiveRecord::Migration
  def up
    add_column :stabs, :subpart_id, :integer 
    remove_column :stabs, :question_id
  end

  def down
    add_column :stabs, :question_id, :integer
    remove_column :stabs, :subpart_id
  end
end
