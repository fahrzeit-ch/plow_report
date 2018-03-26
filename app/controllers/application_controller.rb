class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_season
  helper_method :selected_season
  helper_method :current_driver
  helper_method :current_company

  before_action :authenticate_user!

  def current_season
    @current_season ||= Season.new
  end

  def current_driver
    return nil unless user_signed_in?
    current_user.drivers.last
  end

  # @return [Company]
  def current_company
    return nil unless user_signed_in?
    # Currently only 1 company is supported
    @current_company ||= current_user.companies.last
  end

  # @param [Company | NilClass] company
  def current_company=(company)
    raise 'must be a company' unless company.nil? || company.is_a?(Company)
    raise 'company must be persisted' unless company.nil? || company.persisted?

    @current_company = company
  end

  def selected_season
    return @season if @season

    # load from params and update session
    unless params[:season].blank?
      @season = Season.from_sym params[:season]
      session[:season] = params[:season]
    end

    # load from session or use default
    if session[:season]
      @season = Season.from_sym session[:season]
    else
      @season = current_season
    end
    @season
  end
end
