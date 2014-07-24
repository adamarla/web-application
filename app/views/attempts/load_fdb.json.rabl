
object false 
  node(:id) { @g.id }
  node(:comments) { @comments.map{ |c| {x: c.x, y: c.y, comment: c.tex_comment.text } } }
  node(:preview, unless: @g.scan.nil?){ { source: :locker, images: [@g.scan] } }
  node(:criteria) { Criterion.where(id: @criterion_ids).map{ |j| { text: j.text } } }
  node(:solution) { !@g.scan.nil? }
  node(:audit) { !@g.scan.nil? }
  node(:regrade) { @g.regradeable? }
