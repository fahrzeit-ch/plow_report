class Company::DrivesController < ApplicationController
  before_action :set_company_from_param
  before_action :set_drive, only: [:destroy, :edit, :update]
  helper_method :selected_driver

  def index
    authorize current_company, :index_drives?
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

  def edit
  end

  def update
    if @drive.update(drive_params)
      flash[:success] = I18n.t 'flash.drives.updated'
      redirect_to company_drives_path current_company
    else
      render :edit
    end
  end

  private

  def apply_scopes(drives)
    drives = drives.by_season(selected_season).includes(:driver)
    drives = drives.where(driver_id: params[:driver_id]) unless params[:driver_id].blank?
    drives.order(start: :desc)
  end

  def drive_params
    params.require(:drive).permit(:start, :end, :distance_km, :salt_refilled, :salt_amount_tonns, :salted, :plowed)
  end

  def set_drive
    @drive = current_company.drives.find(params[:id])
    authorize @drive
  end
end
