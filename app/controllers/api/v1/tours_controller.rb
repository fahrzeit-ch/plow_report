# frozen_string_literal: true

class Api::V1::ToursController < Api::V1::ApiController
  def index
    since = params[:changed_since] || 6.months.ago
    @records = Tour.with_discarded
                   .changed_since(since)
                   .where(driver_id: driver_id)
                   .order(sort_params(:start_time, :desc))
                   .page(params[:page])
                   .per(params[:per_page])
  end

  def history
    @since = params[:changes_since] || 1.week.ago
    @records = Audited::Audit
                   .where(auditable_type: Tour.model_name.to_s)
                   .where("created_at >= ?", @since)
                   .order(created_at: :asc).page(params[:page]).per(params[:per_page] || 500)
  end

  def destroy
    @record = Tour.where(driver_id: driver_id).find(params[:id])
    authorize @record
    if @record.discard
      head :no_content
    else
      render json: { error: @record.errors }, status: :bad_request
    end
  end

  def update
    @record = Tour.where(driver_id: driver_id).find(params[:id])
    authorize @record
    if @record.update update_attributes
      head :no_content
    else
      render json: { error: @record.errors }, status: :bad_request
    end
  end

  def create
    @record = Tour.new(create_attributes)
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
      params.permit(policy(Tour).permitted_attributes(:api_update))
    end

    def create_attributes
      params.require([:driver_id, :start_time, :created_at])
      params.permit(policy(Tour).permitted_attributes(:api_create))
    end
end
