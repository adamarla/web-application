class RemoveKlassFromQuiz < ActiveRecord::Migration
  def up
    remove_column :quizzes, :klass
  end

  def down
    add_column :quizzes, :klass, :integer
  end
end
