class AddQualityFlagsToResponses < ActiveRecord::Migration
  def change
    add_column :graded_responses, :weak, :boolean 
    add_column :graded_responses, :medium, :boolean 
    add_column :graded_responses, :strong, :boolean 
  end
end
