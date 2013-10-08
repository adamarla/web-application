
object false
  node(:a) { encrypt(@ws.id,7) }
  node(:b) { @quiz.id }
  node(:c) { @ws.id }
  node(:d) { @student.id }
  node(:e) { encrypt(@relative_index,3) }
  node(:caption) { @ws.name }

  node(:preview) {
    { :id => "ws/#{encrypt(@ws.id,7)}/student/#{encrypt(@relative_index,3)}/#{@images}", :scans => [*1..@quiz.span?] }
  } 
