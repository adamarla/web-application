
# partial 'quizzes/preview', :object => @quiz

object false
  node(:preview, unless: @relative_index.blank?) {
    { id: "ws/#{encrypt(@ws_id,7)}/student/#{encrypt(@relative_index,3)}/preview", scans: [*1..@quiz.span?] }
  } 

  node(:preview, if: @relative_index.blank?) {
    { id: @quiz.uid, scans: [*1..@quiz.span?] }
  }

  node(:a) { @quiz.uid }
  node(:caption) { @quiz.name }
