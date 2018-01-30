class DashboardController < ApplicationController
  def index
    @standby_weeks = StandbyDate.where(driver: current_driver).by_season(selected_season).weeks
    @last_drives = Drive.where(driver: current_driver).by_season(selected_season).order(start: :desc).limit(10)
  end
end
