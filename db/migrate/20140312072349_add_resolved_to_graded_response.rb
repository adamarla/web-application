class AddResolvedToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :resolved, :boolean, default: false
  end
end
