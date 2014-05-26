
object false 
  node(:deployment) { @dep }
  node(:new) { @newbie }
  node(:who, unless: @who.nil? ) { @who }
  node(:monitor) {
    { 
      quizzes: (@q.blank? ? [] : @q.map(&:id)), 
      exams: (@e.blank? ? [] : @e.map(&:id)) 
    }
  }

  # node(:demos, unless: @demos.blank?) {
  #  @demos.map{ |m| { id: m.parent_id, path: m.download_pdf? } }
  #}
