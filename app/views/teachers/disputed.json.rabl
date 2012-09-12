
# JSON = { disputed : [{ disputed : {...}}, {disputed : { ... }} ], preview : { id : [..], scans : [...] } }

node(:disputed) { 
  @disputed.map{ |m| {:disputed => {
    :id => m.id, 
    :name => m.name?, 
    :ticker => m.student.name, 
    :constant => "#{m.system_marks} / #{m.subpart.marks}" }   } }
} 

node(:preview) { 
  { 
    :id => @disputed.map{ |m| "#{m.testpaper.quiz_id}-#{m.testpaper_id}" }, 
    :scans => @disputed.map{ |m| [m.scan] } 
  }
} 

