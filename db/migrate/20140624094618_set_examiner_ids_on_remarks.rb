class SetExaminerIdsOnRemarks < ActiveRecord::Migration
  def up
    Remark.all.each do |r| 
      r.update_attribute :examiner_id, r.examiner_id? 
    end 
  end

  def down
  end
end
