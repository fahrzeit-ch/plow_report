class DashboardController < ApplicationController
  def index
    @standby_weeks = StandbyDate.weeks
    @last_drives = Drive.order(start: :desc).limit(10)
  end
end
