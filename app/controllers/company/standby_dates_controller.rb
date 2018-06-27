class Company::StandbyDatesController < ApplicationController

  before_action :set_company_from_param
  helper_method :selected_driver

  def index
    authorize current_company, :index_standby_dates?
    @standby_dates = StandbyDate.where(driver: current_company.drivers).includes(:driver).by_season(selected_season).all
  end

  def weeks
    authorize current_company, :index_standby_dates?
    @standby_weeks = StandbyDate.where(driver: selected_driver).by_season(selected_season).weeks
  end

  def create
    @standby_date = build_resource

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
    driver = StandbyDate.joins(:driver)
        .where(drivers: {company_id: current_company.id}).find(params[:id])
    authorize driver
    driver.destroy

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

  def build_resource
    resource = resource_class.new self.send(resource_type.to_s + '_params')
    authorize resource
    resource
  end

  def resource_class
    return StandbyDate if resource_type == :standby_date
    return StandbyDate::DateRange if resource_type == :standby_date_date_range
    raise Error, "Unknown resource type #{resource_type}"
  end

  def resource_type
    params.has_key?(:standby_date) ? :standby_date : :standby_date_date_range
  end

  def standby_date_date_range_params
    params.require(:standby_date_date_range).permit(:driver_id, :start_date, :end_date)
  end

  def standby_date_params
    params.require(:standby_date).permit(:driver_id, :day)
  end

end