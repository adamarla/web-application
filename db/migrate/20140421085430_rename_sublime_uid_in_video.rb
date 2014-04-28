class RenameSublimeUidInVideo < ActiveRecord::Migration
  def change 
    rename_column :videos, :sublime_uid, :uid
    rename_column :videos, :sublime_title, :title
  end 
end
