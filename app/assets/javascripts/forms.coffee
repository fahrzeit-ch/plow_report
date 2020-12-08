# Fetch all the forms we want to apply custom Bootstrap validation styles to

formatTime = (dateObject) ->
  hour = dateObject.getHours()
  minutes = dateObject.getMinutes()
  hour = '0' + hour if hour < 10
  minutes = '0' + minutes if minutes < 10
  return hour + ':' + minutes

$(document).on 'turbolinks:load', ->
# Select2
  $('[data-s2]').select2();

  # Update select 2 after carusel slid
  $('#finish-drive-form').on 'slid.bs.carousel', ->
      $('[data-s2]').select2();


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

  $("[data-submit-on-change]").on 'change', ->
    target = $(this).closest('form')
    $(target).submit();

  $('[data-value-field]').on 'change', ->
    data = $(this).data('value-field')
    visibility = data['collapse']
    label = data['label']
    $('#activity_value_label').html(label)
    $('#activity_value').collapse(visibility)