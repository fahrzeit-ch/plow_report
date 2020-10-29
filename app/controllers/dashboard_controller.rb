# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :check_driver!

  def index
    @last_drives = Drive.where(driver: current_driver).kept.by_season(selected_season).order(start: :desc).limit(10)
    @next_standby_date = StandbyDate.where(driver: current_driver).upcoming.first
  end


  private
    def load_standby_weeks
      @standby_weeks = StandbyDate.where(driver: current_driver).by_season(selected_season).weeks
    end
end
