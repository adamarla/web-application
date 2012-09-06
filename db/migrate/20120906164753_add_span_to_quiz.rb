class AddSpanToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :span, :integer
  end
end
