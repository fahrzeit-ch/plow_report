class Api::V1::ApiController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :doorkeeper_authorize!

  def user_not_authorized
    head :unauthorized
  end

  def record_not_found
    render json: { error: "Record could not be found" }, status: :not_found
  end

  def server_error(e)
    render json: { error: "Server Error" }, status: 500
  end

  protected

  def sort_params(default_column, default_direction)
    col = params[:sortBy] || default_column
    dir = params[:sortDir] || default_direction
    { col => dir }
  end

  def company_id
    current_company.id
  end

  def current_company
    return nil if params[:company_id].nil?
    @company ||= current_resource_owner
            .companies
            .select(:id)
            .find!(params[:company_id])
  end

  def driver_id
    @driver_id ||= current_resource_owner
                        .drivers
                        .select(:id)
                        .find(params[:driver_id]).id
  end

  def pundit_user
    @authorization_context ||= current_resource_owner
  end

  # Find the user that owns the access token
  def current_resource_owner
    @user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end