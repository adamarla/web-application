
object false
  node(:questions) {
    selections = QSelection.where(:quiz_id => @quiz.id).order(:index)
    selections.map { |m|
      q = m.question
      { 
        :name => "Ques ##{m.index} (#{q.simple_uid})", 
        :id => q.id, 
        :tag => "#{q.span?} pg" 
      } 
    }
  }
