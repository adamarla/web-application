class AddIndexesToQuiz < ActiveRecord::Migration
  def change
    add_index :quizzes, :teacher_id
  end
end
