
object false 
  node(:exams) { 
    @exams.map{ |m| 
      if @who == 'Student'
        display_tag = m.closed_on?.strftime('%b %Y')
        w = Worksheet.where(exam_id: m.id, student_id: current_account.loggable_id).first
        k = w.nil? ? :disabled : (w.received?(:none) ? :disabled : w.perception?)
      else 
        display_tag = m.name.split('_').first
        k = nil 
      end 
      { 
        id: m.id, 
        name: m.quiz.name, 
        tag: display_tag,
        klass: k,
        badge: (m.takehome ? 'icon-home' : 'icon-print')
      } 
    }
  } 

  node(:user) { @who }
  node(:ping) { @exams.count }
