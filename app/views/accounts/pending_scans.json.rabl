
# Known: The Question and the Quiz. Example: All Q6 (a | b |c)

object false 

node(:pending) {
  @scans.map{ |s| 
    cnd = @pending.where(scan: s).order(:subpart_id) 
    { 
      marker: s, 
      tag: cnd.map(&:student).first.abbreviated_name,
      gr: cnd.map{ |g| 
        {
          marker: g.id, 
          tag: g.name?, 
          shadow: g.shadow?
        }
      }
    }
  }
}

node(:comments){
  @comments.map(&:text)
}

node(:sandbox) { @sandboxed } 
