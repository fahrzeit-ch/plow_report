# Evalute start dates for calendarview based on season
# and parms
class CalendarStartdateEvaluator
  def self.resolve_start_date(params, season)
    return params[:start_date].to_date if params.has_key?(:start_date)

    if season == Season.current
      Date.current
    else
      last_stand_by = StandbyDate.last_in_season(season)
      last_stand_by ? last_stand_by.day : season.start_date
    end
  end
end