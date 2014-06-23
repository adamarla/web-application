
object false 
  node(:criteria) {
    { used: [],
      available: [ { text: @c.text, id: @c.id, reward: @c.reward?, kb: @c.shortcut? } ],
      type: :criteria }
  }
    
