class CreateDailyQuizzes < ActiveRecord::Migration
  def change
    create_table :daily_quizzes do |t|
      t.string :qids 
      t.timestamps
    end
  end
end
