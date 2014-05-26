
object false
  node(:compiled){ !@w.nil? }
  node(:paid_for){ @w.nil? ? false : @w.billed }
  node(:sid) { @sid }
  node(:qid) { @qid }
