class RecordingsController < ApplicationController

  def create
    current_driver.start_recording
    redirect_back fallback_location: root_path
  end

end