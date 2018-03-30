class Company::DriversController < ApplicationController

  def index
    @drivers = current_company.drivers
  end

  # Creates a new driver for this company
  # assigned to the user
  def create
    driver_service = DriverService.new current_user
    if params[:user_id].blank?
      # create a new driver without user assignement
      driver_service.create_company_driver current_company, driver_params
    else
      user = User.find(params[:driver][:user_id])
      driver_service.add_driver current_company,user, params[:driver][:transfer_private]
    end
  end

  def destroy
  end

  private
    def set_company
      self.current_company = Company.find(params[:company_id])
    end

    def driver_params
      params.require(:driver).permit(:user_id, :name)
    end

end