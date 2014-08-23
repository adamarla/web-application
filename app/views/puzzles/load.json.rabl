
object false 
  node(:puzzle, unless: @p.nil?){ 
    { id: @p.id, text: @p.text }
  } 
