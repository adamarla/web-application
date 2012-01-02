
# Function call : samuraiSetHeading e, 'click me to expand' 
samuraiSetHeading = (sword, label) ->
  return if not sword.hasClass 'samurai-sword'
  header = sword.children().first() # will be an .accordion-heading 
  title = header.children().first()
  title.text label

samuraiSelectRow = (sword, json, selects, selections, namespace = 'samurai') ->
  return if not sword.hasClass 'samurai-sword'
  marker = json.id

  for label, index in selects
    select = sword.find('.select').eq(index) # find the n-th .select
    id = "samurai-#{label}-#{marker}-#{index}" # id = samurai-klass-2-1
    select.removeClass 'hidden'

    s = select.children 'select:first'
    s.attr 'id', id
    s.attr 'marker', marker
    s.attr 'name', "#{namespace}[#{marker}][#{label}]"

  populateSelectsWithOptions sword, selections

# Function call : samuraiCheckboxRow e, json, ['mcq', 'multi-part']
samuraiCheckboxRow = (sword, json, labels = [], namespace = 'samurai') ->
  return if not sword.hasClass 'samurai-sword'
  marker = json.id

  for label,index in labels
    checkbox = sword.find('.checkbox').eq(index)
    id = "samurai-#{label}-#{marker}-#{index}" # id = samurai-mcq-2-1
    checkbox.removeClass 'hidden'

    l = checkbox.children 'label:first'
    cbox = checkbox.children 'input:first'

    l.attr 'for', id
    l.text "#{label}"

    cbox.attr 'id', id
    cbox.attr 'marker', marker
    cbox.attr 'name', "#{namespace}[#{marker}][#{label}]" # Ex : samurai[2][difficulty]
    cbox.prop 'disabled', false
    cbox.prop 'checked', (if json[label] is null then false else json[label])
  return true

samuraiButtonRow = (sword, json, buttons = []) ->
  return if not sword.hasClass 'samurai-sword'
  marker = json.id

  for b,index in buttons
    button = sword.find('.button').eq(index)
    button.attr 'marker', marker
    button.val b
    button.removeClass 'hidden'
    button.prop 'disabled', false

samuraiSetupHidden = (sword, json, namespace = 'samurai') ->
  marker = json.id
  ninja = sword.children().eq(1).children('input[type="hidden"]:first')
  $(ninja).attr 'name', "#{namespace}[#{marker}][ninja]"

window.samuraiLineUp = (where, json, key, checks = [], selects = [], buttons = [], selections = {}, namespace = 'samurai') ->
  where = if typeof where is 'string' then $(where) else where
  where.append '<div class="samurai-armory"></div>'
  where = where.children '.samurai-armory:first'

  for record in json
    data = record[key]
    sword = $('#toolbox').children('.samurai-sword:first').clone()

    samuraiSetHeading sword, data.name
    samuraiCheckboxRow sword, data, checks, namespace
    samuraiButtonRow sword, data, buttons
    samuraiSelectRow sword, data, selects, selections
    samuraiSetupHidden sword, data, namespace

    for child in sword.children()
      $(child).appendTo where

  where.accordion({header:'.accordion-heading', collapsible:true, active:false})
  return true

window.samuraiClosestActiveHeading = (id) ->
  me = if typeof(id) is 'string' then $(id) else id
  armory = me.closest '.samurai-armory'

  if not armory? or armory.length is 0 then return null
  openTab = armory.accordion 'option', 'active'
  return (if openTab < 0 then null else armory.find('.accordion-heading').eq(openTab))


window.samuraiClosestActiveTab = (id) ->
  me = if typeof(id) is 'string' then $(id) else id
  armory = me.closest '.samurai-armory'

  if not armory? or armory.length is 0 then return null
  openTab = armory.accordion 'option', 'active'
  return (if openTab < 0 then null else armory.find('.accordion-content').eq(openTab))


