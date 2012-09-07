class AddClosedToGradedResponses < ActiveRecord::Migration
  def change
    add_column :graded_responses, :closed, :boolean, :default => false
  end
end
