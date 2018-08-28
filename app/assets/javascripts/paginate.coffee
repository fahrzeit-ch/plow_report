$(document).on 'turbolinks:load', ->
  if $('.pagination').length
    $(window).scroll ->
      url = $('.pagination .next').children().first().attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').html('<div class="alert alert-primary"><i class="fa fa-spinner fa-spin" aria-hidden="true"></i></div>')
        $.getScript(url)
    $(window).scroll()