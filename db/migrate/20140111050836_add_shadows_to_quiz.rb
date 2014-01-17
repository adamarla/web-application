class AddShadowsToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :shadows, :string
  end
end
