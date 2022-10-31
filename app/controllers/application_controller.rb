# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ConstraintRouter
  include Pundit::Authorization
  include ConsentVerifier
  include SeasonSelection

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_season
  helper_method :selected_season
  helper_method :current_driver
  helper_method :current_company

  before_action :authenticate_user!
  before_action :check_account!
  before_action :check_consents
  before_action :check_not_app_login!

  layout :determine_layout

  def current_driver
    return nil unless user_signed_in?
    @current_driver ||= current_user.drivers.last
  end

  # @return [Company]
  def current_company
    return nil unless user_signed_in?
    # Currently only 1 company is supported
    @current_company ||= default_company_from_driver_or_user
  end

  # @param [Company | NilClass] company
  def current_company=(company)
    raise "must be a company" unless company.nil? || company.is_a?(Company)
    raise "company must be persisted" unless company.nil? || company.persisted?

    @current_company = company
  end



  def redirect_to_referral(fallback_location: nil)
    redirect_to session.delete(:return_to) || fallback_location
  end

  def store_referral
    session[:return_to] ||= request.referer
  end

  protected
    def pundit_user
      @auth_context || AuthContext.new(current_user, current_company, current_driver)
    end

    def user_not_authorized
      flash[:alert] = t("pundit.default")
      redirect_back(fallback_location: root_path)
    end

    def set_company_from_param
      self.current_company = Company.find_by(slug: params[:company_id])
    end

    def default_company_from_driver_or_user
      if current_driver&.company
        current_driver.company
      else
        current_user.companies.last
      end
    end

  private
    def determine_layout
      if user_signed_in?
        "application"
      else
        "public"
      end
    end
end
