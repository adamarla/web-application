class TrimQuiz < ActiveRecord::Migration
  def up
    change_table :quizzes do |t|
      t.remove :uid
      t.remove :num_students
    end
  end

  def down
    change_table :quizzes do |t|
      t.string :uid
      t.integer :num_students
    end
  end
end
