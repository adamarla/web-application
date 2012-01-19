class AddKlassSubjectToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :klass, :integer
    add_column :quizzes, :subject_id, :integer
  end
end
