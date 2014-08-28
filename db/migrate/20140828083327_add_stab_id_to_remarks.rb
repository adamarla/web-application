class AddStabIdToRemarks < ActiveRecord::Migration
  def change
    add_column :remarks, :stab_id, :integer 
    add_index :remarks, :stab_id
  end
end
