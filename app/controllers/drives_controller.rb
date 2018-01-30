class DrivesController < ApplicationController
  before_action :set_drive, only: [:show, :edit, :update, :destroy]

  # GET /drives
  # GET /drives.json
  def index
    @drives = Drive.where(driver: current_driver).by_season(selected_season).all
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
        format.html { redirect_to @drive, notice: 'Drive was successfully created.' }
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
        format.html { redirect_to @drive, notice: 'Drive was successfully updated.' }
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
      format.html { redirect_to drives_url, notice: 'Drive was successfully destroyed.' }
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
