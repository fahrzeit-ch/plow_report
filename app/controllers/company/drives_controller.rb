class Company::DrivesController < ApplicationController
  before_action :set_company

  def index
    @drives = apply_scopes(current_company.drives)
  end

  def show
  end

  def destroy
  end

  private
  def set_company
    self.current_company = Company.find(params[:company_id])
  end

  def apply_scopes(drives)
    drives = drives.by_season(current_season).includes(:driver)
    drives.where(driver_id: params[:driver_id]) unless params[:driver_id].blank?
    drives
  end
end
