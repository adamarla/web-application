
object false 
  node(:a){ @e.path? }
  node(:b){ @e.id }
  node(:has_apprentices){ @e.quiz.teacher.apprentices.count > 0 }
  node(:no_disputes) { Dispute.in_exam(@e.id).count == 0 }
