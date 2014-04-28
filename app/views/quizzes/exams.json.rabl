
object false 
  node(:exams) {
    @exams.map { |m|
      { name: "#{m.created_at.to_date.strftime('%B %d, %Y')}", id: m.id, badge: "#{@chronological.index(m) + 1}" }
    }
  } 

  node(:last_pg) { @last_pg }
