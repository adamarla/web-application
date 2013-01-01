

window.grdTabs = {
  ul : null,
  current : null,

  initialize : () ->
    ul = $('#tab-honest').closest('ul') unless ul?
    grdTabs.current = ul.children('li').eq(0)
    $(m).addClass 'disabled' for m in grdTabs.current.siblings('li')
    a = grdTabs.current.children('a').attr 'id'
    karo.tab.enable a
    return true

}
