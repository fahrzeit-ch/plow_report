$(document).on 'turbolinks:load', ->
  $('a[data=print]').on 'click', (e)->
    window.print()
    e.preventDefault()
    e.stopPropagation()
