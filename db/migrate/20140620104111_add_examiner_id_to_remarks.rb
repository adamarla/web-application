class AddExaminerIdToRemarks < ActiveRecord::Migration
  
  def up 
    add_column :remarks, :examiner_id, :integer 
    Remark.all.each do |r| 
      r.update_attribute :examiner_id, r.examiner_id? 
    end 
    add_index :remarks, :examiner_id
  end 

  def down 
    remove_index :remarks, :examiner_id 
    remove_column :remarks, :examiner_id
  end 
end
