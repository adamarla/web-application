class AddAtmKeyToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :atm_key, :integer
  end
end
