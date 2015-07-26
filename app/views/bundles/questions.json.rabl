object false
  node(:questions) {
    @bqs.map{ |m|
      { :uid => m.question.uid, :label => m.label }
    }
  }

