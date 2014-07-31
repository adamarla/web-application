
object false 
  node(:hints, unless: @id.nil?) { # subpart.hints
    @hints.map{ |j| { index: j.index, text: j.text } } 
  } 
  node(:hints, if: @id.nil?) { # question.hints
    ids = @hints.map(&:subpart_id).uniq
    ids.map{ |j| { "#{j}" => @hints.where(subpart_id: j).order(:index).map(&:text)  } } 
  } 
  node(:id){ @id } 
