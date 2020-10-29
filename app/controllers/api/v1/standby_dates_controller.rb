# frozen_string_literal: true

class Api::V1::StandbyDatesController < Api::V1::ApiController
  def index
    _from = params[:from] ? params[:from] : Date.current
    _until = params[:until] ? params[:until] : Date.current.end_of_month
    @records = StandbyDate.joins(:driver)
                         .where(driver_id: driver_id)
                         .from_date(_from).until_date(_until)
                         .select("standby_dates.*, drivers.name")
  end

  def upcoming
    @record = StandbyDate.where(driver_id: driver_id).upcoming.first
  end

  private
    def calendar_start_date
      ::CalendarStartdateEvaluator.resolve_start_date(params, Season.current)
    end
end
