class RenameParentIdColumnInStudents < ActiveRecord::Migration
  def change 
    rename_column :students, :parent_id, :guardian_id
  end 
end
