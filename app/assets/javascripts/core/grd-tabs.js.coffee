

window.grdTabs = {
  ul : null,

  initialize : () ->
    ul = $('#tab-honest').closest('ul') unless ul?
    first = ul.children('li').eq(0)
    $(m).addClass 'disabled' for m in first.siblings('li')
    a = first.children('a').attr 'id'
    karo.tab.enable a
    return true
    
}
