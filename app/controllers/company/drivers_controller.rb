class Company::DriversController < ApplicationController

  def index
    @drivers = current_company.drivers
  end

  # Creates a new driver for this company
  # assigned to the user
  def create
    driver_service = DriverService.new current_user
    if params[:driver][:user_id].blank?
      # create a new driver without user assignement
      driver_service.create_company_driver current_company, driver_params
    else
      user = User.find(params[:driver][:user_id])
      driver = driver_service.add_driver current_company, user, params[:driver][:transfer_private]
      if driver.persisted?
        flash[:success] = I18n.t 'flash.drivers.created'
      else
        flash[:error] = I18n.t 'flash.drivers.driver_not_created'
      end
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
    def set_company
      self.current_company = Company.find(params[:company_id])
    end

    def driver_params
      params.require(:driver).permit(:name)
    end

end