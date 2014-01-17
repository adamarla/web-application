class RenameCommentsTable < ActiveRecord::Migration
  def change 
    rename_table :comments, :tex_comments
  end 
end
