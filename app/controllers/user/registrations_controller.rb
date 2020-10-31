# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  before_action :restrict_demo_user, only: [:update, :edit]
  skip_before_action :check_account!


  def create
    super do |resource|
      AdminMailer.signup_notification_mail.deliver
    end
  end

  private
    def restrict_demo_user
      if current_user.demo_user?
        raise Pundit::NotAuthorizedError
      end
    end

  protected
    def after_sign_up_path_for(resource)
      stored_location_for(:user) || setup_path
    end

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up) do |user|
        user.permit(:email, :password, :password_confirmation, :name, terms: PolicyTerm.pluck(:key))
      end
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end
end
