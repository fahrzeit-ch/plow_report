class DrivesController < ApplicationController
  before_action :check_driver!
  before_action :set_drive, only: [:show, :edit, :update, :destroy]

  # GET /drives
  # GET /drives.json
  def index
    @drives = Drive.where(driver: current_driver).by_season(selected_season).order(start: :desc).all
  end

  # GET /drives/suggested_values?[salted=true]&[plowed=true]&[salt_refilled=true]
  def suggested_values
    opts = params.permit(:plowed, :salted, :salt_refilled)
    opts.each { |k,v| opts[k] = ActiveModel::Type::Boolean.new.cast(v) }
    @suggested_values = Drive.suggested_values(current_driver, opts)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { render json: @suggested_values.as_json, status: :ok }
    end
  end

  # GET /drives/1
  # GET /drives/1.json
  def show
  end

  # GET /drives/new
  def new
    @drive = Drive.new
  end

  # GET /drives/1/edit
  def edit
  end

  # POST /drives
  # POST /drives.json
  def create
    @drive = Drive.new({driver_id: current_driver.id}.merge(drive_params))

    respond_to do |format|
      if @drive.save
        format.html { redirect_to drives_path, notice: t('flash.drives.created') }
        format.json { render :show, status: :created, location: :index }
      else
        format.html { render :new }
        format.json { render json: @drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drives/1
  # PATCH/PUT /drives/1.json
  def update
    respond_to do |format|
      if @drive.update(drive_params)
        format.html { redirect_to drives_path, notice: t('flash.drives.updated') }
        format.json { render :show, status: :ok, location: :index }
      else
        format.html { render :edit }
        format.json { render json: @drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drives/1
  # DELETE /drives/1.json
  def destroy
    @drive.destroy
    respond_to do |format|
      format.html { redirect_to drives_path, notice: t('flash.drives.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_drive
    @drive = Drive.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def drive_params
    params.require(:drive).permit(:start, :end, :distance_km, :salt_refilled, :salt_amount_tonns, :salted, :plowed)
  end
end
