
collection @publishable => :testpapers 
  attribute :id
  node(:name) { |m| m.quiz.name }
  node(:ticker) do |m| 
    a = AnswerSheet.where(:student_id => @student.id, :testpaper_id => m.id).first 
    "#{a.marks?} / #{a.graded_thus_far?}" 
  end

  node(:atm) { |m| m.quiz.atm_key }
