# frozen_string_literal: true

class AuthorizationsController < Doorkeeper::AuthorizationsController
  include Devise::Controllers::StoreLocation
  prepend_before_action :store_location!, only: :new

  # TODO: Handle raise invalid authorization
  def create
    redirect_or_render authorize_response
    warden.logout
  end

  private
    def store_location!
      store_location_for(:user, request.original_url)
    end
end
