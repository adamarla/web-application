class RenameDbTable < ActiveRecord::Migration
  def change 
    rename_table :db_questions, :questions
  end 
end
