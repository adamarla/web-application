class AddIndexesToGradedResponse < ActiveRecord::Migration
  def change
    add_index :graded_responses, :student_id
    add_index :graded_responses, :q_selection_id
    add_index :graded_responses, :testpaper_id
  end
end
