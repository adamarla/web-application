class CreateSuggestedQuestions < ActiveRecord::Migration
  def change
    create_table :suggested_questions do |t|
      t.integer :suggestion_id
      t.integer :question_id

      t.timestamps
    end
  end
end
