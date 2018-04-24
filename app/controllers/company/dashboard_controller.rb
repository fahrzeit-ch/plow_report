class Company::DashboardController < ApplicationController

  def index
    @statistics = current_company.statistics(current_season)
    @last_drives = current_company.drives.order(start: :desc).limit(10)
  end

end