
object false 
  node(:audit) { 
    @questions.map{ |m|
      { name: "#{m.uid}", id: m.id }
    }
  } 
