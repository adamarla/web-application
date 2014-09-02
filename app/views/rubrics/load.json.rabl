
object false 
  node(:type) { :criteria }
  node(:context) { @ctx }
  node(:id) { @rbid }

  node(:used, if: @ctx == 'edit') {
    @used.map{ |c| { id: c.id, text: c.text, kb: c.shortcut, reward: c.reward?, color: c.perception? } } 
  }
  node(:used, if: @ctx == 'grade') {
    @used.map{ |c| { id: c.id, text: c.text, kb: c.shortcut, color: c.perception? } } 
  }
  node(:used, if: @ctx == 'view') {
    @used.map{ |c| { id: c.id, text: c.text, reward: c.reward?, color: c.perception? } } 
  }

  node(:available, if: @ctx == 'edit'){ 
    @available.map{ |c| { id: c.id, text: c.text, kb: c.shortcut, color: c.perception?, reward: c.reward? } } 
  }

  node(:a) { @rbid }
