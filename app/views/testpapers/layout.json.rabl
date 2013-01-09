
object false 
  node(:tabs) {
    @subparts.map{ |m| 
      {
        :name => m.name_if_in?(@ws.quiz_id), 
        :id => @gr.where(:subpart_id => m.id).map(&:id).first,
        :split => @gr.where(:subpart_id => m.id).map(&:marks?).first
      } 
    } 
  } 

  node(:user) { @who }

  node(:preview) { 
    { :id => "#{@ws.quiz_id}-#{@ws.id}", :scans => @gr.with_scan.map(&:scan).uniq.sort }
  } 
