$(document).on 'turbolinks:load', ->
  activity_value_locked = false
  distance_locked = false
  salt_amount_locked = false

  $('#activity_value_field').on 'keydown', ->
    activity_value_locked = true
  # Lock values after manual change
  $('#drive_distance_km').on 'keydown', ->
    distance_locked = true

  selected_activity_id = 0
  activity_select = $('input[name=drive\\[activity_execution_attributes\\]\\[activity_id\\]]')

  activity_select.on "change", ->
    # unlock activity_value when activity changed
    activity_value_locked = false
    selected_activity_id = $('input[name=drive\\[activity_execution_attributes\\]\\[activity_id\\]]:checked').val()
    load_suggestion(getOpts())

  getOpts = ->
    return {
      activity_id: selected_activity_id
    }

  load_suggestion = (opts) ->
    if !(distance_locked && salt_amount_locked)
      $.get '/drives/suggested_values.json', opts, (data) ->
        if !distance_locked
          $('#drive_distance_km').val(data.distance_km)
        if !salt_amount_locked
          $('#drive_salt_amount_tonns').val(data.salt_amount_tonns)



