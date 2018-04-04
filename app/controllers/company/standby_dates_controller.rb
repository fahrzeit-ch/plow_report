class Company::StandbyDatesController < ApplicationController

  before_action :set_company_from_param
  helper_method :selected_driver

  def index
    @standby_dates = StandbyDate.where(driver: current_company.drivers).includes(:driver).by_season(selected_season).all
  end

  def weeks
    @standby_weeks = StandbyDate.where(driver: selected_driver).by_season(selected_season).weeks
  end

  def create
    @standby_date = StandbyDate.new(standby_date_params)

    respond_to do |format|
      if @standby_date.save
        format.html { redirect_back fallback_location: company_standby_dates_path(current_company), notice: t('flash.standby_dates.created') }
      else
        flash[:error] = I18n.t 'flash.standby_dates.not_created'
        format.html { redirect_back fallback_location: company_standby_dates_path(current_company) }
      end
    end
  end

  def destroy
    StandbyDate.joins(:driver)
        .where(drivers: {company_id: current_company.id})
        .delete(params[:id])

    respond_to do |format|
      format.html { redirect_back fallback_location: company_standby_dates_path(current_company), notice: t('flash.standby_dates.destroyed') }
    end
  end

  def selected_driver
    if params[:driver_id].blank?
      current_company.drivers.first
    else
      Driver.find(params[:driver_id])
    end
  end

  private

  def standby_date_params
    params.require(:standby_date).permit(:driver_id, :day)
  end

end