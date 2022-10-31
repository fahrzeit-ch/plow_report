# frozen_string_literal: true

require "active_support/concern"

module ConstraintRouter
  extend ActiveSupport::Concern

  # Check account for sufficient setup, or redirect accordingly
  def check_account!
    return unless current_user
    return if current_user.company_members.any?
    if current_user.has_driver?
      # This case should not happen, it mens that a driver is assigned, but the user
      # is not member of a company
      redirect_to account_error_path
    else
      redirect_to setup_path unless controller_name == "sessions"
    end
  end

  def check_not_app_login!
    return unless current_user
    if current_user.app_login?
      redirect_to is_app_login_error_path
    end
  end

  # Redirect to company path if user has no driver.
  # This filter should be called *after* check account, otherwise
  # it may raise an error if user has no company.
  def check_driver!
    return unless current_user
    return if current_user.has_driver?
    redirect_to company_dashboard_path(current_user.companies.first)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User) && resource.companies.any?
        company_dashboard_path(current_user.companies.first)
      else
        super
      end
  end
end
