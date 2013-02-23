
object false
  node(:questions) {
    @questions.map { |m|
      {:datum => {:name => m.simple_uid, :id => m.id, :tag => "#{m.span?} pg" } }
    }
  }
