
object false
  node(:a) { @quiz.uid }
  node(:b) { @quiz.id }
  node(:c) { @ws.id }
  node(:d) { @student.id }

  node(:preview) {
    { :id => "#{@quiz.uid}", :scans => [*1..@quiz.span?] }
  } 
