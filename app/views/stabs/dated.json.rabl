
object false 
  node(:stabs, unless: @stabs.blank?) { 
    @stabs.map{ |j| {id: j.id, q: j.question_id, v: j.version, scans: j.kaagaz.map{ |k| { id: j.id, path: k.path }  } } }
  } 
