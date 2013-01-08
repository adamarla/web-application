
jQuery ->

  # Update any non-ajax URLs in #toolbox-menus. These menus would cloned and 
  # re-attached later - by which time their href's should be in order 

  $('body').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    json = $.parseJSON xhr.responseText

    menu.update json, url
    return true

