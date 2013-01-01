class AddFeedbackToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :feedback, :integer, :default => 0
  end
end
