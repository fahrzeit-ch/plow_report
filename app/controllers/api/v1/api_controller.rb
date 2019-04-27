class Api::V1::ApiController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_action :doorkeeper_authorize!

  def user_not_authorized
    head :unauthorized
  end
end