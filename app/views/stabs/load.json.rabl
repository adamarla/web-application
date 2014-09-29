
object false 
  node(:preview) {
    { source: :locker, images: @kgz.map{ |j| { path: j.path, kgz: j.id }} }
  } 

  node(:id) { @stb.id }
  node(:kgz) { @kgz.map{|j| {id: j.id, comments: j.remarks.map{ |r| { x: r.x, y: r.y, tex: r.tex_comment.text } } } } }
