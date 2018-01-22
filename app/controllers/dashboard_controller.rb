class DashboardController < ApplicationController
  def index
    @standby_weeks = StandbyDate.by_season(selected_season).weeks
    @last_drives = Drive.by_season(selected_season).order(start: :desc).limit(10)
  end
end
