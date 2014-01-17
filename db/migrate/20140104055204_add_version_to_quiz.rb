class AddVersionToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :version, :string, limit: 10
  end
end
