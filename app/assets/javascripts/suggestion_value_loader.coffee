$(document).on 'turbolinks:load', ->
  distance_locked = false
  salt_amount_locked = false

  # Lock values after manual change
  $('#drive_distance_km').on 'keydown', ->
    distance_locked = true
  $('#drive_salt_amount_tonns').on 'keydown', ->
    salt_amount_locked = true

  refill_chk = $('#drive_salt_refilled[data-suggest]')
  plowed_chk = $('#drive_plowed[data-suggest]')
  salted_chk = $('#drive_salted[data-suggest]')

  refill_chk.on "change", ->
    load_suggestion(getOpts())
  plowed_chk.on "change", ->
    load_suggestion(getOpts())
  salted_chk.on "change", ->
    load_suggestion(getOpts())

  getOpts = ->
    return {
      salt_refilled: refill_chk.is(":checked")
      plowed: plowed_chk.is(":checked")
      salted: salted_chk.is(":checked")
  }

  load_suggestion = (opts) ->
    if !(distance_locked && salt_amount_locked)
      $.get '/drives/suggested_values.json', opts, (data) ->
        if !distance_locked
          $('#drive_distance_km').val(data.distance_km)
        if !salt_amount_locked
          $('#drive_salt_amount_tonns').val(data.salt_amount_tonns)



