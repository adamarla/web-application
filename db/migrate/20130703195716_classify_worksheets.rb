class ClassifyWorksheets < ActiveRecord::Migration
  def change 
    rename_column :testpapers, :inboxed, :takehome
    add_column :testpapers, :duration, :integer
    add_column :testpapers, :deadline, :datetime
  end
end
