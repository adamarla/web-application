
object false 
  node(:sektion) {
    [{ id: @sk.id, name: @sk.name?, tag: @sk.uid }]
  }

  node(:tabs) { 
    [{ id: @sk.id, name: @sk.name? }]
  }
