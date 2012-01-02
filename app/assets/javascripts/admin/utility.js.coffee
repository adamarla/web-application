
window.resetMicroTopicList = () ->
  source = $('#edit-syllabi-form') # the only other place micro-topics could be
  target = $('#micro-topic-list')

  for list in source.find 'div[back-to]'
    list = $(list).detach()
    list.appendTo target
    list.addClass 'hidden'

    for knife in list.children()
      swissKnifeReset $(knife)
  return true

resetMacroTopicList = () ->
  source = $('#macro-topic-list')
  target = $('#macro-topic-list .dump:first')

  for tray in source.find '.in-tray:first, .out-tray:first'
    for knife in $(tray).find '.swiss-knife'
      knife = $(knife).detach()
      swissKnifeReset knife
      knife.appendTo target
  return true
      
window.buildSyllabiEditForm = (json) ->
  target = $('#edit-syllabi-form .peek-a-boo:first')

  # 1. Move all micro back to #micro-topic-list 
  resetMicroTopicList()

  # 2. Bring back whichever micros are required
  for m in json
    macro = m.macro
    continue if macro.in is false
    list = $('#micro-topic-list').children("div[marker=#{macro.id}]").first()
    list.appendTo target

  # 3. Customize the swiss-knife for each micro-topic within the form
  for micro in target.find('div[marker] > .swiss-knife')
    swissKnifeCustomize $(micro), {select:true}, true

  # 4. Load micro-topic information in the JSON onto the form
  for m in json
    macro = m.macro
    continue if macro.in is false
    e = target.children "div[marker=#{macro.id}]:first" # containing <div>
    micros = macro.micros
    for n in micros
      micro = n.micro
      f = e.children "div[marker=#{micro.id}]:first" # swiss-knife
      select = f.children '.select:first'
      select.val "#{micro.select}"

###
  Shows the list of macros covered by a course. The passed JSON
  is assumed to have at least 2 fields : id (of the macro) and a 
  boolean 'in' for whether or not the macro is covered in a course
###

window.displayMacroList = (json, options = {radio:true, checkbox:false, select:false, button:false}) ->
  resetMacroTopicList()
  start = $('#macro-topic-list .dump:first')
  for record in json
    macro = record['macro']
    covered = macro.in
    id = macro.id

    chosenOne = start.find ".swiss-knife[marker=#{id}]:first"
    swissKnifeCustomize chosenOne, options, covered

    if covered is true
      target = $('#macro-topic-list .in-tray:first')
    else
      target = $('#macro-topic-list .out-tray:first')

    chosenOne = chosenOne.detach()
    chosenOne.appendTo target

###
  Given the JSON response of 'questions/list.json', populates #document-preview
  for use by Popeye plugin
###

window.prepareTBDSlideShow = (json) ->
  baseUrl = "https://github.com/abhinavc/RiddlersVault/raw/master"
  target = $('#document-preview').find 'ul:first'

  for record in json
    question = record['question']
    relPath = question.name # actually, its the path. But in questions/list.rabl, we override the key name
    folder = relPath.split('/').pop() # from X/Y/1_5, extract 1_5
    full = "#{baseUrl}/#{relPath}/#{folder}-answer.jpeg"
    thumb = "#{baseUrl}/#{relPath}/#{folder}-thumb.jpeg"

    preview = $("<li><a href=#{full}><img src=#{thumb} alt=#{folder}/></a></li>")
    preview.appendTo target

  $('#document-preview').popeye()

