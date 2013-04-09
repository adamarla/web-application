
object false
  node(:questions) {
    @questions.map{ |m|
      {
        :name => m.simple_uid,
        :id => m.id
      }
    }
  }

  node(:topic) { @topic }
  node(:last_pg) { @last_pg }
  node(:pg) { @pg }
  node(:context) { @context }
