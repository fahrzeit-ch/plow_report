module DurationHelper
  def justify_hours(hours)
    hours.to_s.rjust(2, '0')
  end

  def seconds_to_h_min(seconds)
    minutes = (seconds / 60).round #ignore seconds
    hours = (minutes / 60) # do not round here as we will display minutes

    parts = []
    parts << "#{hours}h" if hours > 0
    parts << "#{(minutes % 60)}min"

    parts.join(' ')
  end
end