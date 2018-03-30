class Company::StandbyDatesController < ApplicationController

  before_action :set_company_from_param

  def index
    @standby_weeks = StandbyDate.where(driver: current_driver).by_season(selected_season).weeks
    @standby_dates = StandbyDate.where(driver: current_driver).by_season(selected_season).all
  end

  def create
  end

  def destroy
  end

end