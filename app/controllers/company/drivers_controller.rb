class Company::DriversController < ApplicationController

  before_action :set_company_from_param
  before_action :set_driver, only: [:destroy, :edit, :update]

  def index
    @drivers = current_company.drivers.order(:name)
  end

  # Creates a new driver for this company
  # assigned to the user
  def create
    authorize_create_action
    result = current_company.add_driver user_to_assign, params[:driver][:transfer_private]
    if result[:driver].persisted?
      flash[:success] = I18n.t 'flash.drivers.created'
    else
      flash[:error] = I18n.t 'flash.drivers.driver_not_created'
    end
    redirect_to company_drivers_path(current_company)
  end

  def edit
  end

  # Only assigning a user to an unassigned driver is possible
  # Params:
  #   user_id: id of the user
  #
  # Responds with 422 Error when driver already has a user assigned.
  # Respons with 422 Error if the given user is not member of the company
  #
  def update
    # check if user
    return head :unprocessable_entity if @driver.user

    if @driver.update(driver_update_params)
      flash[:success] = I18n.t 'flash.drivers.updated'
      redirect_to company_drivers_path(current_company)
    else
      render :edit
    end
  rescue ActiveRecord::RecordNotFound => e
    head :unprocessable_entity
  end

  def destroy
    if @driver.destroy
      flash[:success] = I18n.t 'flash.drivers.destroyed'
    else
      flash[:error] = I18n.t 'flash.drivers.not_destroyed'
    end
    redirect_to company_drivers_path(current_company)
  end

  private
  def set_driver
    @driver = current_company.drivers.find(params[:id])
    authorize @driver
  end

  def authorize_create_action
    # Just create a dummy driver to authorize against
    authorize Driver.new(user: user_to_assign, company: current_company)
  end

  def driver_params
    params.require(:driver).permit(:name)
  end

  def driver_update_params
    p = params.require(:driver).permit(:user)
    user = User.available_as_driver(current_company).find(p[:user])
    p[:user] = user
    p
  end

  def user_to_assign
    User.find(params[:driver][:user_id])
  end

end