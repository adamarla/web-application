class AddParentIdToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :parent_id, :integer
    add_index :quizzes, :parent_id
  end
end
