# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('.autoselect').on 'focus', () ->
    el = this
    setTimeout () ->
      el.select()
    , 50

  $('.autosubmit').on 'change', () ->
    $(this).closest('form').submit()
