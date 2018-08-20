module CalendarHelper
  def calendar_url_for_today()
    p = params.merge!({start_date: Date.current})
    p.permit!
    url_for()
  end

  # Adds a link to the current url with param start_date: today so
  # simple calendar will align itself to the current date
  def calendar_today_link()
    link_to calendar_url_for_today, class: 'btn btn-default', title: t('simple_calendar.jump_to_today') do
      '<i class="fa fa-calendar-check-o"></i>'.html_safe
    end
  end
end

