module SeasonSelection
  def selected_season
    return @season if @season

    # update session
    session[:season] = params[:season] unless params[:season].blank?
    @season = session[:season] ? Season.from_sym(session[:season]) : current_season
  end

  # Returns the Season that represents the actual season at point in time.
  def current_season
    @current_season ||= Season.new
  end
end