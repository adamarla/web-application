
object false 
  node(:criteria) {
    { used: [],
      available: [ { name: @c.text, id: @c.id, n_stars: @c.num_stars? } ],
      type: :criteria }
  }
    
