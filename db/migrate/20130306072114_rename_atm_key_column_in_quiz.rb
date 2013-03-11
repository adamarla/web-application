class RenameAtmKeyColumnInQuiz < ActiveRecord::Migration
  def change 
    rename_column :quizzes, :atm_key, :uid
  end 
end
