class Company::DrivesController < ApplicationController
  before_action :set_company_from_param
  before_action :set_drive, only: [:destroy, :edit, :update]

  after_action :update_read_status, only: :index
  helper_method :selected_driver

  def index
    authorize current_company, :index_drives?
    scope = apply_scopes(current_company.drives
                             .kept
                             .without_tour
                             .with_viewstate(current_user)
                             .includes(:driver, :activity_execution, :site, :activity, :customer))
    @drives = scope.order(start: :desc)

    respond_to do |format|
      format.html do
        @stats = apply_scopes(current_company.drives).stats
        @drives = @drives.includes(:activity, :customer).page(params[:page]).per(30)
      end
      format.js do
        @drives
      end
      format.xlsx do
        @drives
      end
    end
  end

  def destroy
    store_referral
    if @drive.discard
      flash[:success] = I18n.t 'flash.drives.destroyed'
    else
      flash[:error] = I18n.t 'flash.drives.not_destroyed'
    end
    redirect_to_referral fallback_location: company_drives_path(current_company)
  end

  def edit
    store_referral
  end

  def update
    if @drive.update(drive_params)
      flash[:success] = I18n.t 'flash.drives.updated'
      redirect_to_referral fallback_location: company_drives_path(current_company)
    else
      render :edit
    end
  end

  private

  def update_read_status
    new_drives = @drives.reject(&:seen?)
    UpdateReadStatusJob.perform_later(current_user.id, new_drives.pluck(:id), 'Drive') if new_drives.any?
  end

  def apply_scopes(drives)
    drives = drives.by_season(selected_season)
    drives = drives.where(driver_id: params[:driver_id]) unless params[:driver_id].blank?
    drives = drives.where(customer_id: params[:customer_id]) unless params[:customer_id].blank?
    drives
  end

  def drive_params
    permitted = policy(Drive).permitted_attributes
    permitted << :driver_id
    params.require(:drive).permit(permitted)
  end

  def set_drive
    @drive = current_company.drives.find(params[:id])
    authorize @drive
  end
end
