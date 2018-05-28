# Fetch all the forms we want to apply custom Bootstrap validation styles to

formatTime = (dateObject) ->
  hour = dateObject.getHours()
  minutes = dateObject.getMinutes()
  hour = '0' + hour if hour < 10
  minutes = '0' + minutes if minutes < 10
  return hour + ':' + minutes

$(document).on 'turbolinks:load', ->
  forms = document.getElementsByClassName('needs-validation');

  # Auto update timefield until focus
  cancel_tic = false
  auto_set_time = $("[data-tic-time]")
  auto_set_time.on 'keydown', () ->
    cancel_tic = true

  tic = ()->
    time = new Date()
    # TODO: This is not working yet. The format is not correct (it results in 3:3 instead of 03:03
    formatted_time = formatTime(time)
    auto_set_time.val(formatted_time)
    unless cancel_tic
      setTimeout(tic, 2000)

  if auto_set_time.length >= 0
    tic()

  # Loop over them and prevent submission
  validation = Array.prototype.filter.call forms, (form) ->
    form.addEventListener 'submit', (event) ->
      if (form.checkValidity() == false)
        event.preventDefault()
        event.stopPropagation()

      form.classList.add('was-validated')

  $("[data-collapse-on-change]").on 'change', ->
    target = $(this).data('collapse-on-change')
    $("#" + target).collapse('toggle')