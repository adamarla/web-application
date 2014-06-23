
object false 
  node(:criteria) {
    { used: [],
      available: [ { text: @c.text, id: @c.id, badge: @c.badge?, kb: @c.shortcut? } ],
      type: :criteria }
  }
    
