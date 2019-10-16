class AuthorizationsController < Doorkeeper::AuthorizationsController

  # TODO: Handle raise invalid authorization
  def create
    redirect_or_render authorize_response
    warden.logout
  end

  private

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