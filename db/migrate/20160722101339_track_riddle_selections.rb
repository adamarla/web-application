class TrackRiddleSelections < ActiveRecord::Migration
  def change 
    add_column :usages, :num_snippets_clicked, :integer, default: 0
    add_column :usages, :num_questions_clicked, :integer, default: 0
  end 
end
