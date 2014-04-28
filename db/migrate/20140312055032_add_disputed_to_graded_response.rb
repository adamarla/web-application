class AddDisputedToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :disputed, :boolean, default: false
  end
end
