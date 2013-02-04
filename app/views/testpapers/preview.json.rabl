
# partial 'quizzes/preview', :object => @quiz

object false
  node(:preview) {
    { :id => @quiz.atm_key, :scans => [*1..@quiz.span?] } 
  } 
  node(:a) { @quiz.atm_key }
  node(:caption) { @quiz.name }
