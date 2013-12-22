
object false 
  node(:exams) {
    @exams.map { |m|
      if m.takehome?
        icons = m.duration.nil? ? "icon-home" : "icon-home icon-time"
      else
        icons = "icon-time"
      end
      { :name => "#{m.name}", :tag => "#{m.created_at.to_date.strftime('%b %Y')}", :id => m.id, :icons => icons }
    }
  } 

  node(:last_pg) { @last_pg }
