class RenameGradeToKlassInStudyGroup < ActiveRecord::Migration
  def change
    rename_column :study_groups, :grade, :klass
  end 
end
