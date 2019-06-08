class Api::V1::DrivesController < Api::V1::ApiController

  rescue_from ActionController::ParameterMissing, with: :handle_param_missing

  def index
    @records = Drive.where(driver_id: driver_id)
                   .includes(:activity_execution)
                   .order(sort_params(:start, :desc))
                   .page(params[:page])
                   .per(params[:per])
  end

  def create
    activity = create_attributes[:activity]
    @record = Drive.new(create_attributes.except(:activity))
    @record.activity_execution_attributes = activity || {}
    if @record.save
      render :create, status: :created
    else
      render json: @record.errors, status: :bad_request
    end
  end


  private

  def handle_param_missing(e)
    render json: { error: e.message }, status: :bad_request
  end

  def create_attributes
    params.require([:driver_id, :start, :end, :created_at])
    params.permit(policy(Drive).permitted_attributes(:api_create))
  end
end
