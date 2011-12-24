
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
  startPt = $('#edit-syllabi-form')

  for m in json
    macro = m.macro
    target = if macro.in is true then startPt.find('.peek-a-boo:first') else startPt.find('.dump:first')
    newNode = $('<div/>', { class : 'hidden', marker : macro.id})
    newNode.appendTo target
    displayJson macro.micros, newNode, 'micro', false, true, true
