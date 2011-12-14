class AddTrackingDataToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :num_students, :integer
    add_column :quizzes, :num_questions, :integer
  end
end
