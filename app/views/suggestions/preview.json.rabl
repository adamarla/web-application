
object false
  node(:preview) {
    {
      source: :locker,
      images: @images 
    }
  }

  node(:a) { "0-#{@sg.teacher_id}/#{@sg.signature}/page-1.jpeg" }
  node(:slots) {
    @sg.questions.map{ |m|
      {
        :id => m.id,
        :name => m.uid,
        :klass => "#{m.topic_id.nil? ? 'disabled' : nil}" 
      }
    }
  }
