class AddUidToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :uid, :string
  end
end
