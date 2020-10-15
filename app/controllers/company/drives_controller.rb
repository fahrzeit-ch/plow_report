class Company::DrivesController < ApplicationController
  before_action :set_company_from_param
  before_action :set_drive, only: [:destroy, :edit, :update]

  after_action :update_read_status, only: :index
  helper_method :selected_driver

  def index
    authorize current_company, :index_drives?
    scope = apply_scopes(current_company.drives
                             .kept
                             .with_viewstate(current_user)
                             .includes(:driver, :activity_execution, :site, :activity, :customer))
    @drives = scope.order(start: :desc)

    respond_to do |format|
      format.html do
        @stats = apply_scopes(current_company.drives).stats
        @drives = @drives.includes(:activity, :customer).page(params[:page]).per(30).without_tour
      end
      format.js do
        @drives.without_tour
      end
      format.xlsx do
        @drives = @drives.includes(:tour)
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

  def new
    store_referral
    @drive = Drive.new fetch_defaults(params)
    authorize @drive
    if tour
      render 'company/tours/drives/new'
    end
  end

  def create
    @drive = Drive.create(drive_params)
    authorize @drive
    if @drive.valid?
      flash[:success] = I18n.t 'flash.drives.created'
      redirect
    else
      render :edit
    end
  end

  def edit
    if tour
      render 'company/tours/drives/edit'
    end
  end

  def update
    if @drive.update(drive_params)
      flash[:success] = I18n.t 'flash.drives.updated'
      redirect
    else
      render :edit
    end
  end

  private

  def redirect
    if @drive.tour
      redirect_to edit_company_tour_path(current_company, @drive.tour)
    else
      redirect_to company_drives_path(current_company)
    end
  end

  def fetch_defaults(params)
    if tour
      start_time = tour.last_drive.try(:end) || tour.start_time
      { start: start_time, end: start_time + 30.minutes, driver: tour.driver, tour_id: params[:tour_id] }
    end
  end

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

  def tour
    if params[:tour_id]
      @tour ||= Tour.find(params[:tour_id])
    end
  end

  def set_drive
    @drive = current_company.drives.find(params[:id])
    authorize @drive
  end
end
