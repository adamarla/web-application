class RenameOnPaperColumn < ActiveRecord::Migration
  def change 
    rename_column :riddles, :on_paper, :has_draft
    rename_column :skills, :on_paper, :has_draft
  end 
end
