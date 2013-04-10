
# @ongoing = array of Questions - not Suggestions!

object false
  node(:typeset) { 
    @ongoing.map{ |m|
      {
        :id => m.suggestion_id,
        :tag => m.uid
      }
    }
  } 
