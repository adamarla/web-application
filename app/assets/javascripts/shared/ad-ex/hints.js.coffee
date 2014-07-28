
window.hint = {
  modal : null, 
  form : null,

  button : {
    subparts : null 
  }

  initialize : (json) -> 
    unless hint.modal?
      hint.modal = $('#m-edit-hints')[0]
      btns = $(hint.modal).find('#hint-btns')
      hint.button.subparts = btns.children('.btn-group').children('button')
      hint.form = $(hint.modal).find('form')[0]

    # json as returned by question/layout
    return false unless json.subparts?

    for m in $(hint.button.subparts)
      $(m).prop('disabled', true) 
      $(m).removeClass 'active' 

    hint.clear()
    # Enable buttons only for valid number of subparts 
    for j in json.subparts 
      btn = $(hint.button.subparts).filter("[data-index=#{j.index}]")[0]
      if btn?
        $(btn).attr 'href', "load/hints?sbp=#{j.id}"
        $(btn).prop 'disabled', false
        btn.setAttribute 'data-id', j.id

    # Disable form submit button. Enable it when a subpart is selected
    submitBtn = $(hint.form).find('button[type=submit]').eq(0)
    submitBtn.prop 'disabled', true
    return true
  
  clear : () ->
    return false unless hint.modal?
    $(j).val('') for j in $(hint.form).find('input[type=text]')

    $(hint.modal).find('#hint-tex-preview').eq(0).empty()
    return true 

  load : (json) ->
    # json as returned by load/hints
    # There can be a maximum of 3 hints / question only. Any more, and we are 
    # basically giving the solution away

    hint.clear() 
    id = json.id 
    inp = $(hint.form).find('input[type=text]')
    $(i).attr('name', "hint[#{id}][#{j}]") for i,j in inp

    # load json 
    for m,j in json.hints
      i = inp.eq(j)
      i.val karo.unjaxify(m.text)

    # Enable the submit button now that some json has been loaded  
    submitBtn = $(hint.form).find('button[type=submit]').eq(0)
    submitBtn.prop 'disabled', false
    return true

  preview : (inputBox) ->
    tex = $(inputBox).val() 
    target = $(hint.modal).find("#hint-tex-preview")[0]
    $(target).empty() 

    unless /^\s*$/.test(tex)  # not blank, that is
      tex = karo.jaxify tex
      $("<script type='math/tex' id='hint-tex'>#{tex}</script>").appendTo $(target)
      MathJax.Hub.Queue ['Typeset', MathJax.Hub, target]
    return true
      
  current : () ->
    return null unless hint.modal?
    btn = $(hint.button.subparts).filter('[class~=active]')[0]
    return ( if btn? then btn.getAttribute('data-id') else null )
} 

jQuery ->

  $('#m-edit-hints').on 'click', 'button[data-index]', (event) ->
    $.get "load/hints?sbp=#{this.getAttribute('data-id')}", (json) ->
      hint.load(json)
    return true

  $('#m-edit-hints form').submit ->
    inp = $(hint.form).find('input[type=text]')
    allBlank = true
    for i in inp
      v = $(i).val()
      continue if /^\s*$/.test(v) # blank, that is   
      $(i).val karo.jaxify( $(i).val() )
      allBlank = false
    return not allBlank

  $('#m-edit-hints input[type=text]').blur -> 
    hint.preview this
    return true
