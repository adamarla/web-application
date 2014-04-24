
object false 
  node(:lessons) {
    @lessons.map{ |l| { id: l.id, name: l.title, video: l.video.uid } }
  }
