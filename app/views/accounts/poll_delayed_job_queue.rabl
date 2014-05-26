
object false
  
  # Only teachers will get these in response
  node(:indie) { @indie }
  unless @q.blank?
    node(:quizzes) { @q.map { |q| { id: q.id, name: q.name, path: q.download_pdf? } } }
    node(:enable) { @q.map(&:id) }
  end

  node(:exams, unless: @e.blank?) {
    @e.map { |e| { id: e.id, name: "#{e.quiz.name}-#{e.name}", path: e.download_pdf? } }
  }

  # Only a student will get this in response
  unless @w.blank?
    node(:worksheets){ @w.map{ |w| { q: w.exam.quiz_id, name: w.exam.quiz.name, path: w.download_pdf?, id: w.id } } } 
  end
