class Company::DriversController < ApplicationController

  before_action :set_company_from_param

  def index
    @drivers = current_company.drivers
  end

  # Creates a new driver for this company
  # assigned to the user
  def create
    result = current_company.add_driver user_to_assign, params[:driver][:transfer_private]
    if result[:driver].persisted?
      flash[:success] = I18n.t 'flash.drivers.created'
    else
      flash[:error] = I18n.t 'flash.drivers.driver_not_created'
    end
    redirect_to company_drivers_path(current_company)
  end

  def destroy
    if current_company.drivers.destroy params[:id]
      flash[:success] = I18n.t 'flash.drivers.destroyed'
    else
      flash[:error] = I18n.t 'flash.drivers.not_destroyed'
    end
    redirect_to company_drivers_path(current_company)
  end

  private

    def driver_params
      params.require(:driver).permit(:name)
    end

    def user_to_assign
      User.find(params[:driver][:user_id])
    end

end