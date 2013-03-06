
object false
  node(:a) { @student.atm_key }
  node(:b) { @quiz.id }
  node(:c) { @ws.id }
  node(:d) { @student.id }
  node(:caption) { @ws.name }

  node(:preview) {
    { :id => "#{@student.atm_key}/#{@quiz.id}-#{@ws.id}", :scans => [*1..@quiz.span?] }
  } 
