
# JSON = { disputed : [{ disputed : {...}}, {disputed : { ... }} ], preview : { id : [..], scans : [...] } }

node(:disputed) { 
  @disputed.map{ |m| {:disputed => {
    :parent => m.q_selection.quiz_id,
    :id => "#{m.exam.quiz_id}-#{m.exam_id}/#{m.scan}", 
    :name => m.name?, 
    :ticker => m.student.name, 
    :constant => "#{m.system_marks} / #{m.subpart.marks}" }   } }
} 

node(:preview) { 
  { 
    :id => @disputed.map{ |m| "#{m.exam.quiz_id}-#{m.exam_id}" }, 
    :scans => @disputed.map{ |m| [m.scan] } 
  }
} 

node(:quizzes) {
  @quizzes.map{ |m| { :quiz => {:name => m.name, :id => m.id }} }
} 

