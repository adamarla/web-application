
object false
  node(:questions) {
    @questions.map{ |m|
      { :datum => {
          :name => m.simple_uid,
          :id => m.id,
          :tag => "#{m.span?} pg"
        }
      }
    }
  } 

  node(:topic) { @topic }
  node(:last_pg) { @last_pg }
  node(:pg) { @pg }
  node(:context) { @context }