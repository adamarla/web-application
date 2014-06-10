
object false 
  node(:exams) {
    @exams.map { |m|
      if m.takehome 
        tokens = m.name.split('_')
        tag = tokens.last 
        title = tokens.first 
      else 
        tag = nil
        title = m.name 
      end 
      { name: title, id: m.id, badge: (m.takehome ? 'icon-home' : 'icon-print'), tag: tag } 
    }
  } 

  node(:last_pg) { @last_pg }
