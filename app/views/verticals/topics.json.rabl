
object false 
  node(:topics) {
    @topics.map{ |m|
      { :topic => {
          :name => m.name, 
          :id => m.id
        }
      }
    }
  } 

  node(:disable) { @unused }
