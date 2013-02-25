
object false
  node(:preview) {
    {
      :id => "0-#{@suggestion.teacher_id}",
      :scans => [@suggestion.signature]
    }
  } 
