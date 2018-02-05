class StandbyDateRangesController < ApplicationController

  # POST /standby_dates
  # POST /standby_dates.json
  def create
    @standby_date_range = StandbyDate::DateRange.new({driver_id: current_driver.id}.merge(standby_date_params))

    respond_to do |format|
      if created_dates = @standby_date_range.save
        format.html { redirect_to standby_dates_path, notice: t('flash.standby_date_ranges.created', num: created_dates.length ) }
        format.json { render :show, status: :created, location: standby_dates_path }
      else
        format.html { render :new }
        format.json { render json: @standby_date_range.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def standby_date_params
      params.require(:standby_date_date_range).permit(:start_date, :end_date)
    end
end
