
# @ongoing = array of Questions - not Suggestions!

object false
  node(:typeset) { 
    @ongoing.map{ |m|
      {
        :name => m.suggestion.teacher.name,
        :id => m.suggestion_id,
        :tag => m.uid
      }
    }
  } 
