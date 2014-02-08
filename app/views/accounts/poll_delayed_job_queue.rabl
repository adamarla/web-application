
object false
  node(:quizzes, unless: @q.blank?) { 
    @q.map { |q| { id: q.id, name: q.name, path: q.download_pdf? } }
  }

  node(:exams, unless: @e.blank?) {
    @e.map { |e| { id: e.id, name: "#{e.quiz.name}-#{e.name}", path: e.download_pdf? } }
  }
  
  node(:enable) { @q.map(&:id) }

  # node(:demo) { 
  #   @demo.map { |m| { :id => m.quiz.parent_id, :a => encrypt(m.id, 7), :b => m.quiz_id, :c => m.id } }
  # } 
