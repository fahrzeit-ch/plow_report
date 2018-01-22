class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_season
  helper_method :selected_season

  def current_season
    @current_season ||= Season.new
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
