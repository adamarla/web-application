class AddMarksToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :marks, :integer
  end
end
