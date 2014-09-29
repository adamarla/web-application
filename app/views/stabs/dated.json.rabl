
object false 
  node(:stabs, if: @is_examiner) { 
    @stabs.map{ |j| {id: j.id, 
                     q: j.question_id, 
                     v: j.version,
                     scans: j.kaagaz.map{ |k| { id: k.id, path: k.path }  } } }
  }

  node(:stabs, unless: @is_examiner){
    @stabs.map{ |j| { id: j.id, 
                      q: j.question_id, 
                      v: j.version, 
                      name: j.question.topic.name, 
                      tag: Stab.quality_defn(j.quality) } }
  }
