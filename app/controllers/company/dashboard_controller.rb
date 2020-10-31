# frozen_string_literal: true

class Company::DashboardController < ApplicationController
  def index
    @statistics = current_company.statistics(current_season)
    @last_drives = current_company.drives.kept.with_viewstate(current_user).order(start: :desc).limit(10)

    new_drives = @last_drives.reject(&:seen?)
    if new_drives.any?
      UpdateReadStatusJob.perform_later(current_user.id, new_drives.pluck(:id), "Drive")
    end
  end
end
