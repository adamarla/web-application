
object false
  node(:preview) {
    {
      :id => "0-#{@suggestion.teacher_id}/#{@suggestion.signature.split('.')[0]}",
      :scans => @suggestion.expand_pages()
    }
  } 
