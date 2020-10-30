# frozen_string_literal: true

class User::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:accept_invitation) do |user_params|
        user_params.permit(:invitation_token, :password, :password_confirmation, terms: PolicyTerm.pluck(:key))
      end
    end
end
