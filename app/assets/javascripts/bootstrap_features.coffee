myDefaultWhiteList = $.fn.tooltip.Constructor.Default.whiteList

myDefaultWhiteList.dd = [];
myDefaultWhiteList.dl = [];
myDefaultWhiteList.dt = [];

$(document).on 'turbolinks:load', ->
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover({ whiteList: myDefaultWhiteList })
  $('label > a').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()