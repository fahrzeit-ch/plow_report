class AuthorizationsController < Doorkeeper::AuthorizationsController

  include Devise::Controllers::StoreLocation
  prepend_before_action :store_location!

  # TODO: Handle raise invalid authorization
  def create
    redirect_or_render authorize_response
    warden.logout
  end

  private

  def store_location!
    store_location_for(:user, request.original_url)
  end

  def render_success
    if skip_authorization? || matching_token?
      redirect_or_render authorize_response
      warden.logout
    elsif Doorkeeper.configuration.api_only
      render json: pre_auth
    else
      render :new
    end
  end

end