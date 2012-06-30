class AddIndexToSuggestedQuestions < ActiveRecord::Migration
  def change
    add_index :suggested_questions, :suggestion_id
    add_index :suggested_questions, :question_id, unique: true
  end
end
