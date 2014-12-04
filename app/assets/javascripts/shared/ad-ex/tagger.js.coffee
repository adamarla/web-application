
History = (nd) -> 
  this.node = nd

  this.list = new Array() 

  this.add = (tag, blind = false) ->
    if blind 
      this.list.push(tag) 
    else 
      missing = true 
      for j in this.list 
        missing |= (tag is j)
        break unless missing 
      this.list.push(tag) if missing 
    return true

  this.load = (json) ->
    # json assumed to be an array of strings.
    this.add(j, true) for j in json
    return true

window.tagger = { 
  list : null,

  add : (nd) ->
    tagger.list = new Array() unless tagger.list?  
    m = tagger.find nd 
    return false if m?
    n = new History(nd)
    tagger.list.push n
    # Now, call tagit() on 'nd'
    $(nd).tagit({ autocomplete: { delay: 0, minLength: 2, source: n.list }, allowSpaces: true })
    return true 

  find : (nd) ->
    return null unless tagger.list?
    for j in tagger.list 
      return j if j.node is nd 
    return null
}
