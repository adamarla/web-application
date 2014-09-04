
object false 
  node(:dated, unless: @dated.blank?) { 
    @dated.map{ |j| {id: j.id, q: j.question_id, v: j.version, scans: j.kaagaz.map{ |k| { id: k.id, path: k.path }  } } }
  } 
