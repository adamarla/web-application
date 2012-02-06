class RenamePathInQuestion < ActiveRecord::Migration
  def change 
    rename_column :questions, :path, :uid
  end 
end
