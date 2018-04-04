# Fetch all the forms we want to apply custom Bootstrap validation styles to
$(document).on 'turbolinks:load', ->
  forms = document.getElementsByClassName('needs-validation');
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