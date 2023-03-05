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

  if navigator.userAgent.search("Safari") != -1 && navigator.userAgent.search("Chrome") == -1
    # For Safari, we add a mask, as native datetime picker is not available
    $('input[type="datetime-local"]').flatpickr({
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      time_24hr: true,
      minuteIncrement: 1,
    })


  $('[data-daterange]').each ->
    defaults = {
      "locale": {
        "format": "DD.MM.YYYY",
        "separator": " - ",
        "applyLabel": "Anwenden",
        "cancelLabel": "Abbrechen",
        "fromLabel": "Von",
        "toLabel": "Bis",
        "customRangeLabel": "Benutzerdefiniert",
        "weekLabel": "W",
        "daysOfWeek": [
          "So",
          "Mo",
          "Di",
          "Mi",
          "Do",
          "Fr",
          "Sa"
        ],
        "monthNames": [
          "Januar",
          "Februar",
          "März",
          "April",
          "Mai",
          "Juni",
          "Juli",
          "August",
          "September",
          "Oktober",
          "November",
          "Dezember"
        ],
        "firstDay": 1
      },
      "timePicker24Hour": true,
      "timePickerIncrement": 1
      "timePicker": true,
      "ranges": {
        'Heute': [moment().startOf('day'), moment().endOf('day')],
        'Gestern': [moment().subtract(1, 'days').startOf('day'), moment().subtract(1, 'days').endOf('day')],
        'Letze 7 Tage': [moment().subtract(6, 'days').startOf('day'), moment().endOf('day')],
        'Diesen Monat': [moment().startOf('month').startOf('day'), moment().endOf('month').endOf('day')],
        'Letzten Monat': [moment().subtract(1, 'month').startOf('month').startOf('day'), moment().subtract(1, 'month').endOf('month').endOf('day')]
        'Dieses Jahr': [moment().startOf('year').startOf('day'), moment().endOf('day')]
      }
    }
    _self = $(this)
    targetStart = _self.data('target-start')
    targetEnd = _self.data('target-end')
    options = $.extend(true, {}, defaults, _self.data('daterange'))

    if(targetStart)
      _self.daterangepicker options, (start, end) ->
        $(targetStart).val(start.toISOString())
        $(targetEnd).val(end.toISOString())
        _self.find('span').html(start.format(options.locale.format) + ' - ' + end.format(options.locale.format))
    else
      _self.daterangepicker options

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

  $("[data-disable-on-change]").on 'change', ->
    target = $(this).data('disable-on-change')
    $("#" + target).prop("disabled", !this.checked );

  $("[data-submit-on-change]").on 'change', ->
    target = $(this).closest('form')
    $(target).submit();

  $('[data-value-field]').on 'change', ->
    data = $(this).data('value-field')
    visibility = data['collapse']
    label = data['label']
    $('#activity_value_label').html(label)
    $('#activity_value').collapse(visibility)