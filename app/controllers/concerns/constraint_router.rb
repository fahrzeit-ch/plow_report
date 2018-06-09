require 'active_support/concern'

module ConstraintRouter

  extend ActiveSupport::Concern

  # Check account for sufficient setup, or redirect accordingly
  def check_account!
    return unless current_user
    return if current_user.has_driver? || current_user.companies.any?
    redirect_to setup_path unless controller_name == 'static_pages'
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
        if resource.is_a?(User) && resource.has_driver?
          super
        elsif resource.is_a?(User)
          company_dashboard_path(current_user.companies.first)
        else
          super
        end
  end

end