
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

