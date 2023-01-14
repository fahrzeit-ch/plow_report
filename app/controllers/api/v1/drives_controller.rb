# frozen_string_literal: true

class Api::V1::DrivesController < Api::V1::ApiController
  rescue_from ActionController::ParameterMissing, with: :handle_param_missing

  def index
    since = params[:changed_since] || 6.months.ago
    @records = Drive
                   .changed_since(since)
                   .with_discarded
                   .where(driver_id: driver_id)
                   .includes(:activity_execution)
                   .order(sort_params(:start, :desc))
                   .page(params[:page])
                   .per(params[:per_page])
  end

  def history
    @since = params[:changes_since] || 1.week.ago
    @records = Audited::Audit
                .where(auditable_type: "Drive")
                .where("created_at >= ?", @since)
                .order(created_at: :asc).page(params[:page]).per(params[:per_page] || 500)
  end

  def destroy
    @record = Drive.where(driver_id: driver_id).find(params[:id])
    authorize @record
    if @record.discard
      head :no_content
    else
      render json: { error: @record.errors }, status: :bad_request
    end
  end

  def update
    activity = create_attributes[:activity]
    @record = Drive.where(driver_id: driver_id).find(params[:id])
    @record.vehicle_id = @record.tour.try(:vehicle_id)
    authorize @record
    if @record.update update_attributes.to_h.except(:activity).merge(activity_execution_attributes: activity)
      head :no_content
    else
      render json: { error: @record.errors }, status: :bad_request
    end
  end

  def create
    activity = create_attributes[:activity]
    @record = Drive.new(create_attributes.except(:activity))
    @record.vehicle_id = @record.tour.try(:vehicle_id)
    @record.activity_execution_attributes = activity || {}
    authorize @record
    if @record.save
      render :create, status: :created
    else
      render json: { error: @record.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { error: "RecordNotUnique" }, status: :bad_request
  end

  private
    def handle_param_missing(e)
      render json: { error: e.message }, status: :bad_request
    end

    def update_attributes
      params.permit(policy(Drive).permitted_attributes(:api_update))
    end

    def create_attributes
      params.require([:driver_id, :start, :end, :created_at])
      params.permit(policy(Drive).permitted_attributes(:api_create))
    end
end
