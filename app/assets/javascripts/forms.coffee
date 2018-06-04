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
  skip_on_change = false
  auto_set_time = $("[data-tic-time]")
  auto_set_time.on 'change keydown', () ->
    unless skip_on_change
      cancel_tic = true

  tic = ()->
    return if cancel_tic
    time = new Date()
    formatted_time = formatTime(time)
    skip_on_change = true
    auto_set_time.val(formatted_time)
    skip_on_change = false
    setTimeout(tic, 1000)

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