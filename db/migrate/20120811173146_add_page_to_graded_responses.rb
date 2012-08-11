class AddPageToGradedResponses < ActiveRecord::Migration
  def change
    add_column :graded_responses, :page, :integer
  end
end
