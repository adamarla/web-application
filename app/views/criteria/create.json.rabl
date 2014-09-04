
object false 
  node(:criteria) {
    { used: [],
      available: [ { text: @c.text, id: @c.id, reward: @c.reward? } ],
      type: :criteria }
  }
    
