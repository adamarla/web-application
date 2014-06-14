
object false 
  node(:exams) { 
    @exams.map{ |m| 
      display_tag = @who == "Student" ? m.closed_on?.strftime('%b %Y') : m.name.split('_').first
      { 
        id: m.id, 
        name: m.quiz.name, 
        tag: display_tag,
        klass: (@who == "Student" ? Worksheet.where(exam_id: m.id, 
        student_id: current_account.loggable_id).first.honest? : nil),
        badge: (m.takehome ? 'icon-home' : 'icon-print')
      } 
    }
  } 

  node(:user) { @who }
