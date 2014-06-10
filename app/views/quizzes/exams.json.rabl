
object false 
  node(:exams) {
    @exams.map { |m|
      tag = m.created_at.strftime('%b %Y')
      title = m.name.split('_').first
      { name: title, id: m.id, badge: (m.takehome ? 'icon-home' : 'icon-print'), tag: tag } 
    }
  } 

  node(:last_pg) { @last_pg }
