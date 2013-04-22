
object false 
  node(:tabs) {
    @subparts.map{ |m| 
      {
        :name => m.name_if_in?(@ws.quiz_id), 
        :id => @gr.where(:subpart_id => m.id).map(&:id).first,
        :split => @gr.where(:subpart_id => m.id).map(&:marks?).first,
        :colour => @gr.where(:subpart_id => m.id).map(&:honest?).first
      } 
    } 
  } 

  node(:user) { @who }

  node(:preview) { 
    { :id => @root_folder, :scans => @gr.with_scan.map(&:scan).uniq.sort }
  } 

  node(:caption) { @ws.quiz.name }
