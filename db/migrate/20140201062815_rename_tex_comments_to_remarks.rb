class RenameTexCommentsToRemarks < ActiveRecord::Migration
  def change 
    rename_table :tex_comments, :remarks
  end 
end
