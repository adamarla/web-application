class CreateGradedResponses < ActiveRecord::Migration
  def change
    create_table :graded_responses do |t|
      t.integer :quiz_id
      t.integer :question_id
      t.integer :student_id
      t.integer :index_in_quiz
      t.integer :on_page
      t.integer :grade
      t.string :scanned_image

      t.timestamps
    end
  end
end
