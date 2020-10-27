$(document).on 'turbolinks:load', ->
  if $('.pagination').length
    $('#content').scroll ->
      url = $('.pagination .next').children().first().attr('href')
      if url && $('#content').scrollTop() > $('#content').children().first().height() - $('#content').height() - 50
        $('.pagination').html('<div class="alert alert-primary"><i class="fa fa-spinner fa-spin" aria-hidden="true"></i></div>')
        Rails.ajax({
          type: 'get',
          url: url,
          dataType: 'script'
        });
        #$.getScript(url, crossDomain: true)
    $('#content').scroll()