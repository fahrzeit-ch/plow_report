class Api::V1::StandbyDatesController < Api::V1::ApiController

  def index
    @records = StandbyDate.joins(:driver)
                         .where(driver_id: driver_id)
                         .select('standby_dates.*, drivers.name')
                         .by_calendar_month(calendar_start_date)
  end

  def upcoming
    @record = StandbyDate.where(driver_id: driver_id).upcoming.first
  end

  private
  def calendar_start_date
    ::CalendarStartdateEvaluator.resolve_start_date(params, Season.current)
  end
end
