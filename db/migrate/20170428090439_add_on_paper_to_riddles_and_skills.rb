class AddOnPaperToRiddlesAndSkills < ActiveRecord::Migration
  def change
    add_column :riddles, :on_paper, :boolean, default: false 
    add_column :skills, :on_paper, :boolean, default: false 
  end
end
