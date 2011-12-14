class AddExaminerIdToGradedResponse < ActiveRecord::Migration
  def change
    add_column :graded_responses, :examiner_id, :integer
  end
end
