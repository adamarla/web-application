
object false 
  node(:deployment) { @dep }
  node(:new) { @newbie }
  node(:who, unless: @who.nil? ) { @who }
  node(:monitor) {
    { 
      quiz: (@q.blank? ? [] : @q.map(&:id)), 
      exam: (@e.blank? ? [] : @e.map(&:id)) 
    }
  }
