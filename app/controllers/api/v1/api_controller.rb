class Api::V1::ApiController < ActionController::Base
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

  # Find the user that owns the access token
  def current_resource_owner
    @user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end