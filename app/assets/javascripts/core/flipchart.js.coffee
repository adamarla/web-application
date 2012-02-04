
###
  Flip-charts are for all those times when only one panel is available 
  to show nested data. At such times, one begins with some 'top-level' 
  data and then - depending on some selection in that view - dives 
  down to the next level data - rendered in the same panel 

  For the code here to work, it is important that the HTML be 
  written in the 'flipchart' way, that is : 

    %div.flipchart
      %div{ :index => 0 }
      %div{ :index => 1 }
      %div{ :index => 2 }
      %div{ :index => 3 }

  Only the minimal set of elements & attributes is shown above. Each <div> 
  can have other attributes too

  Also, note the 0-indexing above. This is really important in the 'back' 
  and 'forward' methods below 

  The list of of children is also treated as a circularly connected linked list.
  In other words, if you ask to step ahead(behind) the last(first) child, 
  then the methods wrap around to some other child in the list

###

window.flipchart = {
  initialize : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    count = root.children().length
    root.attr 'length', count
    root.attr 'current', 0

    for j in [1...count]
      child = root.children().eq(j)
      child.addClass 'hidden'

    return true

  back : (root, step = 1) ->
    current = root.attr 'current'
    return false if not current?

    length = root.attr('length')
    next = (current - step)
    next = if (next < 0) then (length - ((step - current) % length)) else next
    root.children().eq(current).addClass 'hidden'
    root.children().eq(next).removeClass 'hidden'
    root.attr 'current', next
    return true

  forward : (root, step = 1) ->
    current = root.attr 'current'
    return false if not current?

    length = root.attr('length')
    next = (current + step)
    next = if (next >= length) then ((step - (length - current)) % length) else next
    root.children().eq(current).addClass 'hidden'
    root.children().eq(next).removeClass 'hidden'
    root.attr 'current', next
    return true

  activate : (root, index) ->
    return false if index < 0 or index >= root.attr('length')
    current = root.attr 'current'
    root.children().eq(current).addClass 'hidden'
    root.children().eq(index).removeClass 'hidden'
    root.attr 'current', index
    return true

  last : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return null if not root.hasClass 'flipchart'

    last = root.attr('length') - 1
    return root.children().eq(last)

  first : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return null if not root.hasClass 'flipchart'
    return root.children().eq(0)
}
