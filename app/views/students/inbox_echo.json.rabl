
object false
  node(:a) { @student.uid }
  node(:b) { @quiz.id }
  node(:c) { @ws.id }
  node(:d) { @student.id }
  node(:caption) { @ws.name }

  node(:preview) {
    { :id => "#{@student.uid}/#{@quiz.id}-#{@ws.id}", :scans => [*1..@quiz.span?] }
  } 
