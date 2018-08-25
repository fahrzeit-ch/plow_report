class Company::DashboardController < ApplicationController

  def index
    @statistics = current_company.statistics(current_season)
    @last_drives = current_company.drives.with_viewstate(current_user).order(start: :desc).limit(10)
    UserAction.track_list(current_user, @last_drives.reject(&:seen?))
  end

end