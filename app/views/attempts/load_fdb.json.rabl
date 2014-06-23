
object false 
  node(:id) { @g.id }
  node(:comments) { @comments.map{ |c| {x: c.x, y: c.y, comment: c.tex_comment.text } } }
  node(:preview, unless: @g.scan.nil?){ { source: :locker, images: [@g.scan] } }
  node(:disputed) { @g.disputed }
  node(:criteria) { @criterion_ids }
