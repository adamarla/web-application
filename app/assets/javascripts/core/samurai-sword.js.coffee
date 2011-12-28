
# Function call : samuraiSetHeading e, 'click me to expand' 
window.samuraiSetHeading = (sword, label) ->
  return if not sword.hasClass 'samurai-sword'
  heading = sword.children 'accordion-heading:first'
  heading.text label

# Function call : samuraiCheckboxRow e, json, ['mcq', 'multi-part']
window.samuraiCheckboxRow = (sword, json, labels = []) ->
  return if not sword.hasClass 'samurai-sword'
  marker = json.id

  for label,index in labels
    checkbox = sword.find('.checkbox').eq(index)
    id = "samurai-#{label}-#{marker}-#{index}" # id = samurai-difficulty-2-1

    l = checkbox.children 'label:first'
    cbox = checkbox.children 'input:first'

    l.attr 'for', id
    l.val "#{label}"
    l.removeClass 'hidden'

    cbox.attr 'marker', marker
    cbox.attr 'name', "#{label}[#{marker}]" # Ex: difficulty[2]
    cbox.removeClass 'hidden'
    cbox.prop 'disabled', false
    cbox.prop 'checked', (if json[label] is null then false else json[label])
  return true

