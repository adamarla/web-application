class TrackPgBreaksInQuiz < ActiveRecord::Migration
  def change 
    add_column :quizzes, :page_breaks_after, :string, limit: 30
    add_column :quizzes, :switch_versions_after, :string, limit: 30
  end 
end
