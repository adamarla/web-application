
object false 
  node(:hints, unless: @id.nil?) { # subpart.hints
    @hints.map{ |j| { index: j.index, text: j.text } } 
  } 
  node(:hints, if: @id.nil?) { # question.hints
    @render
  } 
  node(:id, unless: @id.nil?){ @id } 
