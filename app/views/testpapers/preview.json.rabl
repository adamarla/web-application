
# partial 'quizzes/preview', :object => @quiz

object false
  node(:preview) {
    { :id => @quiz.uid, :scans => [*1..@quiz.span?] } 
  } 
  node(:a) { @quiz.uid }
  node(:caption) { @quiz.name }
