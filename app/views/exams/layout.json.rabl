
object false 
  node(:tabs) {
    @qsids.map{ |m| 
      sbp = Question.find(m.question_id).subparts
      sbp.map{ |s|
        a = @gr.where(subpart_id: s.id).first
        {
          name: s.name_if_in?(@exam.quiz_id),
          id: a.id,
          split: (a.marks.nil? ? 'tbd' : a.marks),
          color: a.perception?
        } 
      }
    }.flatten 
  } 

  node(:user) { @who }
  node(:caption) { @exam.quiz.name }
  node(:last_pg, unless: @last_pg.blank?){ @last_pg }
  node(:disputable) { @exam.disputable? }
  node(:notify, unless: @exam.regrade_by.nil?){
    { title: "#{@exam.regrade_by.strftime('%B %d, %Y')}" }
  }
