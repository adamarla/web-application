class ConnectResponseToSelection < ActiveRecord::Migration
  def up
    remove_column :graded_responses, :quiz_id
    remove_column :graded_responses, :question_id
    add_column :graded_responses, :q_selection_id, :integer
  end

  def down
    add_column :graded_responses, :quiz_id, :integer
    add_column :graded_responses, :question_id, :integer
    remove_column :graded_responses, :q_selection_id
  end
end
