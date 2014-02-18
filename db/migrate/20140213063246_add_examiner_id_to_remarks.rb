class AddExaminerIdToRemarks < ActiveRecord::Migration
  def up
    unless Remark.new.respond_to? :live
      add_column :remarks, :examiner_id, :integer
      add_column :remarks, :live, :boolean, default: true
      add_index :remarks, :examiner_id

      Remark.reset_column_information # to ensure model has latest column data

      Remark.all.each do |r|
        eid = r.graded_response.examiner_id
        r.update_attributes examiner_id: eid, live: true
      end
    end
  end

  def down
    remove_column :remarks, :examiner_id
    remove_column :remarks, :live
  end
end
