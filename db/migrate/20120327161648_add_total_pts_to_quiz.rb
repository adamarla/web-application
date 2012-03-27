class AddTotalPtsToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :total, :integer, :default => nil
  end
end
