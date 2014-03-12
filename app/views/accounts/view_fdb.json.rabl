

object false 
  node(:fdb, unless: @fdb.empty? ) { @fdb }
  node(:video, unless: @solution_video.nil?) { @solution_video.sublime_uid }
  node(:id) { @gr.student_id }
  node(:comments, unless: @gr.scan.nil?) { @comments.map{ |c| {x: c.x, y: c.y, comment: c.tex_comment.text } } }
  node(:preview, unless: @gr.scan.nil?) { 
    {
      source: :locker, 
      images: [@gr.scan]
    }
  }
  node(:regrade, unless: @regrade.nil?) { @regrade } 
  node(:a) { @gr.id }
  node(:e) { @gr.worksheet.exam_id }
