
object false 
  node(:comments, unless: @comments.blank?) { @comments.map{ |c| {x: c.x, y: c.y, comment: c.tex_comment.text } } }
  node(:preview, unless: @g.nil?){
    { source: :locker, images: [@g.scan] }
  }
  node(:a, unless: @g.nil?){ @g.id }
