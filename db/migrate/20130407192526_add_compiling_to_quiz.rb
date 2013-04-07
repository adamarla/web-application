class AddCompilingToQuiz < ActiveRecord::Migration
  def up
    remove_column :quizzes, :uid
    add_column :quizzes, :job_id, :integer, :default => -1
  end

  def down
    remove_column :quizzes, :job_id
    add_column :quizzes, :uid, :string, :limit => 20
  end 
end
