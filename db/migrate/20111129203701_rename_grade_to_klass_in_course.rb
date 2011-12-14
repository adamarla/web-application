class RenameGradeToKlassInCourse < ActiveRecord::Migration
  def change 
    rename_column :courses, :grade, :klass
  end 
end
