class AddExaminerIdToRemarks < ActiveRecord::Migration
  
  def up 
    add_column :remarks, :examiner_id, :integer 
    add_index :remarks, :examiner_id
  end 

  def down 
    remove_index :remarks, :examiner_id 
    remove_column :remarks, :examiner_id
  end 
end
