class RenameSyllabiAsCourses < ActiveRecord::Migration
  def change 
    rename_table :syllabi, :courses
  end 
end
