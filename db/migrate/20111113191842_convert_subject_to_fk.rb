class ConvertSubjectToFk < ActiveRecord::Migration
  def change 
    rename_column :courses, :subject, :subject_id
  end 
end
