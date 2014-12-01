
object false 
  node(:deployment) { @dep }
  node(:type, unless: @type.nil? ) { @type }
  node(:admin){ @admin }
  node(:blocked) { @blocked }
  node(:new) { @newbie }
  node(:monitor) {
    { 
      quizzes: (@q.blank? ? [] : @q.map(&:id)), 
      exams: (@e.blank? ? [] : @e.map(&:id)) 
    }
  }

#  node(:puzzle, unless: @puzzle.nil?) { 
#    { id: @puzzle.id, text: @puzzle.text, expiry: @puzzle.expires_in? }
#  } 

