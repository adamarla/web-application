
object false 
  node(:tabs) {
    @qsids.map{ |m| 
      sbp = Question.find(m.question_id).subparts
      sbp.map{ |s|
        {
          name: s.name_if_in?(@exam.quiz_id),
          id: @gr.where(subpart_id: s.id).map(&:id).first,
          split: @gr.where(subpart_id: s.id).map(&:marks?).first,
          colour: @gr.where(subpart_id: s.id).map(&:honest?).first
        } 
      }
    }.flatten 
  } 

  node(:user) { @who }
  node(:caption) { @exam.quiz.name }
  node(:last_pg, unless: @last_pg.blank?){ @last_pg }
