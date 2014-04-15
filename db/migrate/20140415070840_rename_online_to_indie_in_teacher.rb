class RenameOnlineToIndieInTeacher < ActiveRecord::Migration
  def up 
    rename_column :teachers, :online, :indie
    change_column_default :teachers, :indie, true
  end 

  def down
    rename_column :teachers, :indie, :online
    change_column_default :teachers, :online, false 
  end 
end
