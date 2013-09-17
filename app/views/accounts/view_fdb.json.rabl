

object false 
  node(:fdb) { @fdb }
  node(:video, unless: @solution_video.nil?) { @solution_video.sublime_uid }
  node(:ws) { @gr.testpaper_id }
  node(:id) { @gr.student_id }
