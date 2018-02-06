# Fetch all the forms we want to apply custom Bootstrap validation styles to
$(document).on 'ready page:load', ->
  forms = document.getElementsByClassName('needs-validation');
  # Loop over them and prevent submission
  validation = Array.prototype.filter.call forms, (form) ->
    form.addEventListener 'submit', (event) ->
      if (form.checkValidity() == false)
        event.preventDefault()
        event.stopPropagation()

      form.classList.add('was-validated')