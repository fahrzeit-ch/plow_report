# frozen_string_literal: true

require "active_support/concern"

module ConstraintRouter
  extend ActiveSupport::Concern

  # Check account for sufficient setup, or redirect accordingly
  def check_account!
    return unless current_user
    return if current_user.has_driver? || current_user.companies.any?
    redirect_to setup_path unless controller_name == "sessions"
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
