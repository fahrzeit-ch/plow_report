class Api::V1::DrivesController < Api::V1::ApiController

  def index
    @records = Drive.where(driver_id: driver_id).page(params[:page]).per(params[:per])
  end
end
