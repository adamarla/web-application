class SpringCleanApril17 < ActiveRecord::Migration
  def up
    [ :tryouts, 
      :suggestions, 
      :doodles,
      :remarks,
      :stabs, 
      :commentaries,
      :checklists, 
      :courses, 
      :kaagaz,
      :lessons, 
      :criteria, 
      :daily_quizzes, 
      :disputes, 
      :doubts, 
      :hints, 
      :exams, 
      :faculty_rosters, 
      :student_rosters,
      :favourites, 
      :freebies, 
      :grades, 
      :q_selections, 
      :quizzes, 
      :puzzles, 
      :revisions, 
      :rubrics, 
      :schools, 
      :sektions, 
      :guardians, 
      :students, 
      :videos, 
      :subparts, 
      :takehomes, 
      :teachers, 
      :tex_comments, 
      :worksheets,
      :watan ].each do |name| 

      drop_table name if ActiveRecord::Base.connection.table_exists?(name)
    end 
  end

  def down
  end
end
