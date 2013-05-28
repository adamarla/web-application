
object false
  node(:preview) {
    {
      :id => @suggestion.signature, 
      :scans => [*1..@suggestion.pages].map{ |m| "page-#{m}.jpeg" }
    }
  } 
