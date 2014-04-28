class GeneralizeApprenticeship < ActiveRecord::Migration
  def change 
    rename_column :apprenticeships, :examiner_id, :mentee_id
    rename_column :apprenticeships, :teacher_id, :mentor_id
    rename_index :apprenticeships, 'index_apprenticeships_on_examiner_id', 'index_apprenticeships_on_mentee_id'
    rename_index :apprenticeships, 'index_apprenticeships_on_teacher_id', 'index_apprenticeships_on_mentor_id'
  end 
end
