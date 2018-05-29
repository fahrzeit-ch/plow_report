class RecordingsController < ApplicationController

  def create
    current_driver.start_recording
    redirect_back fallback_location: root_path
  end

  def destroy
    current_driver.cancel_recording
    redirect_back fallback_location: root_path
  end

  def finish
    current_driver.finish_recording
    @drive = Drive.new({driver: current_driver}.merge(drive_params))
    if @drive.save
      redirect_to drives_path, flash: { success: I18n.t('flash.drives.created') }
    else
      render 'drives/new'
    end
  end

  private
  def drive_params
    params.require(:drive).permit(:start, :end, :distance_km, :salt_refilled, :salt_amount_tonns, :salted, :plowed)
  end
end