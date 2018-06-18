class Company::DrivesController < ApplicationController
  before_action :set_company_from_param
  before_action :set_drive, only: :destroy
  helper_method :selected_driver

  def index
    @drives = apply_scopes(current_company.drives)
  end

  def destroy
    if @drive.destroy
      flash[:success] = I18n.t 'flash.drives.destroyed'
    else
      flash[:error] = I18n.t 'flash.drives.not_destroyed'
    end
    redirect_to company_drives_path current_company
  end

  private

  def apply_scopes(drives)
    drives = drives.by_season(selected_season).includes(:driver)
    drives = drives.where(driver_id: params[:driver_id]) unless params[:driver_id].blank?
    drives.order(start: :desc)
  end

  def set_drive
    @drive = current_company.drives.find(params[:id])
    authorize @drive
  end
end
