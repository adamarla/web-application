class AddColorFlagsToResponsesAndWorksheets < ActiveRecord::Migration
  def change
    add_column :graded_responses, :orange_flag, :boolean 
    add_column :graded_responses, :red_flag, :boolean 
    add_column :worksheets, :orange_flag, :boolean 
    add_column :worksheets, :red_flag, :boolean 
  end
end
