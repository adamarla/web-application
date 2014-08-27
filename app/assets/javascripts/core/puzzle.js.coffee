
window.puzzle = { 
  source : null, 
  target : null, 

  initialize : (json) -> # json as return by /ping 
    unless json.puzzle?
      if json.type is 'Examiner'
        if json.admin
          puzzle.target = $('#pzl-tex-preview')[0]
          puzzle.source = $('#pzl-tex')[0]

          # Attach event to render the just entered TeX
          $(puzzle.source).blur ->
            puzzle.preview()
            return true
          # Attach onsubmit behaviour to form
          $('#m-new-puzzle form').submit ->
            return puzzle.submit() 
      return false

    puzzle.source = null 
    puzzle.target = $('#pzl-daily')[0]
    tex = json.puzzle.text

    # !Examiner => rendering problem/puzzle of the day!
    # Change styling using MathJax.Hub.Config here itself.
    $("<script type='math/tex' id='hint-tex'>#{tex}</script>").appendTo $(puzzle.target)
    MathJax.Hub.Queue ['Typeset', MathJax.Hub, puzzle.target]
    return true

  jaxify : (tex) ->
    # no sanity checks here. This method will only replace carriage returns 
    # and then jaxify the passed string 
    r = tex.replace(/\r?\n|\r/g,'$\\\\$')
    r = karo.jaxify r 
    return r 

  preview : () -> # only Admins 
    return false unless puzzle.source? 

    tex = $(puzzle.source).val() 
    $(puzzle.target).empty() 

    unless /^\s*$/.test(tex)  # not blank, that is
      tex = puzzle.jaxify tex
      $("<script type='math/tex' id='hint-tex'>#{tex}</script>").appendTo $(puzzle.target)
      MathJax.Hub.Queue ['Typeset', MathJax.Hub, puzzle.target]
    return true

  submit : () -> # only Admins 
    return false unless puzzle.source?
    tex = $(puzzle.source).val()
    return false if /^\s*$/.test(tex) # blank, that is   
    tex = puzzle.jaxify tex
    $(puzzle.source).val tex
    return true
} 
