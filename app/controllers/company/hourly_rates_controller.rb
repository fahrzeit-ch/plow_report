class Company::HourlyRatesController < ApplicationController

  def index
    authorize(current_company, :index_hourly_rates?)

    @base_rate = HourlyRate.where(company_id: current_company.id).base_rate
    @activity_price_rates = ImplicitHourlyRate
                                .where(company_id: current_company.id)
                                .includes(:activity)
                                .activity_rates
                                .sort_by { |one| one.activity.name }
  end

  def create
    @hourly_rate = HourlyRate.new(hourly_rate_create_params.merge company: current_company)
    authorize @hourly_rate
    if @hourly_rate.save
      flash[:success] = t 'flash.common.saved'
      redirect_to company_hourly_rates_path current_company
    else
      flash[:error] = t @hourly_rate.errors.full_messages.join(', ')
    end
  end

  def update
    @hourly_rate = HourlyRate.where(company: current_company).find(params[:id])
    authorize @hourly_rate
    if @hourly_rate.update(hourly_rate_update_params)
      flash[:success] = t 'flash.common.saved'
      redirect_to company_hourly_rates_path current_company
    else
      flash[:error] = t @hourly_rate.errors.full_messages.join(', ')
    end
  end

  def destroy
    @hourly_rate = HourlyRate.find(params[:id])
    authorize @hourly_rate
    if @hourly_rate.destroy
      flash[:success] = t 'flash.common.deleted'
      redirect_to company_hourly_rates_path current_company
    else
      flash[:error] = t @hourly_rate.errors.full_messages.join(', ')
    end
  end

  private
  def hourly_rate_create_params
    params.require(:hourly_rate).permit(:price, :customer_id, :activity_id)
  end

  def hourly_rate_update_params
    params.require(:hourly_rate).permit(:price)
  end

end