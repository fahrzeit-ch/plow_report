class RecordingsController < ApplicationController

  def create
    return already_recording_response if current_driver.recording?

    current_driver.start_recording
    redirect_back fallback_location: root_path
  end

  def destroy
    return not_recording_response unless current_driver.recording?

    current_driver.cancel_recording
    redirect_back fallback_location: root_path
  end

  def finish
    return not_recording_response unless current_driver.recording?

    current_driver.finish_recording
    @drive = Drive.new({driver: current_driver}.merge(drive_params))
    authorize @drive
    if @drive.save
      redirect_to root_path, flash: { success: I18n.t('flash.drives.created') }
    else
      render 'drives/new'
    end
  end

  private
  def drive_params
    params.require(:drive).permit(:start, :end, :distance_km, :salt_refilled, :salt_amount_tonns, :salted, :plowed)
  end

  def already_recording_response
    redirect_to root_path, flash: { error: I18n.t('flash.drives.already_recording') }
  end

  def not_recording_response
    redirect_to root_path, flash: { error: I18n.t('flash.drives.not_recording') }
  end
end