
object false
  node(:a) { @quiz.atm_key }
  node(:b) { @quiz.id }
  node(:c) { @ws.id }
  node(:d) { @student.id }

  node(:preview) {
    { :id => "#{@quiz.atm_key}", :scans => [*1..@quiz.span?] }
  } 
