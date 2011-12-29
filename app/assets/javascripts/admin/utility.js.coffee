
window.ensureMicroListCompleteness = () ->
  source = $('#edit-syllabi-form') # the only other place micro-topics could be
  target = $('#micro-topic-list')

  for list in source.find 'div[back-to]'
    list = $(list).detach()
    list.appendTo target

    for knife in list.children()
      swissKnifeReset $(knife)


window.loadSyllabiEditFormWith = (syllabi) ->
  table = $('#edit-syllabi-megaform')

  for item in syllabi
    topic = item.syllabus.id
    difficulty = item.syllabus.difficulty
    target = table.find "div[marker=#{topic}]"

    continue if target.length is 0

    checkbox = target.find('.checkbox:first').children('input:first')
    dropdown = target.find('.dropdown:first').find('select:first')
    option = dropdown.find "option[value=#{difficulty}]:first"

    checkbox.prop 'checked', true
    dropdown.prop 'disabled', false
    option.prop 'selected', true

window.buildSyllabiEditForm = (json) ->
  target = $('#edit-syllabi-form .peek-a-boo:first')

  # 1. Move all micro back to #micro-topic-list
  for micro in target.children('div[marker]')
    $(micro).addClass 'hidden'
    micro = $(micro).detach()
    $(micro).appendTo '#micro-topic-list'
    swissKnifeReset $(micro)

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
  start = $('#macro-topic-list')
  for record in json
    macro = record['macro']
    covered = macro.in
    id = macro.id

    chosenOne = start.find ".swiss-knife[marker=#{id}]:first"
    swissKnifeCustomize chosenOne, options
    within = chosenOne.closest '.sortable'

    if within.length is 0 #initially
      if covered is true
        target = start.find '.in-tray:first'
        disabled = false
      else
        target = start.find '.out-tray:first'
        disabled = true
    else if within.hasClass 'in-tray'
      continue if covered is true # leave untouched
      target = start.find '.out-tray:first'
      disabled = true
    else
      continue if covered is false # leave untouched
      target = start.find '.in-tray:first'
      disabled = false

    chosenOne = chosenOne.detach()
    chosenOne.appendTo $(target)

    for element in chosenOne.children()
      continue if $(element).hasClass 'hidden'
      $(element).prop 'disabled', disabled
