class RenameTitleToNameInLesson < ActiveRecord::Migration
  def change
    rename_column :lessons, :title, :name
  end
end
