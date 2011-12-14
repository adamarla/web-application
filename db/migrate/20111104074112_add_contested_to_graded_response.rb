class AddContestedToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :contested, :boolean, :default => false
  end
end
