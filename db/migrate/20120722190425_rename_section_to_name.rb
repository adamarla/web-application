class RenameSectionToName < ActiveRecord::Migration
  def change 
    rename_column :sektions, :section, :name
  end 
end
