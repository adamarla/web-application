
# Function call : samuraiSetHeading e, 'click me to expand' 
samuraiSetHeading = (sword, label) ->
  return if not sword.hasClass 'samurai-sword'
  heading = sword.children '.accordion-heading:first'
  heading.text label

# Function call : samuraiCheckboxRow e, json, ['mcq', 'multi-part']
samuraiCheckboxRow = (sword, json, labels = []) ->
  return if not sword.hasClass 'samurai-sword'
  marker = json.id

  for label,index in labels
    checkbox = sword.find('.checkbox').eq(index)
    id = "samurai-#{label}-#{marker}-#{index}" # id = samurai-difficulty-2-1
    checkbox.removeClass 'hidden'

    l = checkbox.children 'label:first'
    cbox = checkbox.children 'input:first'

    l.attr 'for', id
    l.text "#{label}"

    cbox.attr 'id', id
    cbox.attr 'marker', marker
    cbox.attr 'name', "#{label}[#{marker}]" # Ex: difficulty[2]
    cbox.prop 'disabled', false
    cbox.prop 'checked', (if json[label] is null then false else json[label])
  return true

window.samuraiLineUp = (where, json, key, checks = [], selects = [], buttons = []) ->
  where = if typeof where is 'string' then $(where) else where

  for record in json
    samurai = record[key]
    sword = $('#toolbox').children('.samurai-sword:first').clone()

    samuraiSetHeading sword, samurai.name
    samuraiCheckboxRow sword, samurai, checks
    for child in sword.children()
      $(child).appendTo where

    where.accordion( { header:'.accordion-heading', collapsible:true, active:false } )


