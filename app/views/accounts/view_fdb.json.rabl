

object false 
  node(:fdb, unless: @fdb.empty? ) { @fdb }
  node(:video, unless: @solution_video.nil?) { @solution_video.sublime_uid }
  node(:ws) { @gr.testpaper_id }
  node(:id) { @gr.student_id }
  node(:comments, unless: @gr.scan.nil?) { @comments.map{ |c| {x: c.x, y: c.y, comment: c.tex } } }
  node(:preview, unless: @gr.scan.nil?) { 
    {
      source: :locker, 
      images: [@gr.scan]
    }
  }
