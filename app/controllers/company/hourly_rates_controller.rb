class Company::HourlyRatesController < ApplicationController

  def index
    @base_rate = HourlyRate.where(company_id: current_company.id).base_rate
    @activity_price_rates = ImplicitHourlyRate.where(company_id: current_company.id, customer_id: nil)
                                .includes(:activity)

    @activity_price_rates = @activity_price_rates.group_by(&:activity_id)
        .map { |pr_group| pr_group[1].min_by(&:inheritance_level) }
  end

  def create
    @hourly_rate = HourlyRate.new(hourly_rate_create_params.merge company: current_company)
    if @hourly_rate.save
      flash[:success] = t 'flash.common.saved'
      redirect_to company_hourly_rates_path current_company
    else
      flash[:error] = t @hourly_rate.errors.full_messages.join(', ')
    end
  end

  def update
    @hourly_rate = HourlyRate.where(company: current_company).find(params[:id])
    if @hourly_rate.update(hourly_rate_update_params)
      flash[:success] = t 'flash.common.saved'
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