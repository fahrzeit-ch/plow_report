class Company::DrivingRoutesController < ApplicationController
  before_action :set_route, only: %i[edit update destroy]

  def index
    @routes = policy_scope(DrivingRoute).order(:name).page(params[:page]).per(50)
  end

  def new
    @route = DrivingRoute.new(company: current_company)
    authorize @route
  end

  def edit
  end

  def create
    @route = DrivingRoute.new(permitted_attributes(DrivingRoute))
    @route.company = current_company
    authorize @route

    if @route.save
      flash[:success] = I18n.t "flash.driving_route.created"
      redirect_to company_driving_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.driving_route.not_created"
      render :new
    end
  end

  def update
    if @route.update(permitted_attributes(DrivingRoute))
      flash[:success] = I18n.t "flash.driving_route.updated"
      redirect_to company_driving_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.driving_route.not_updated"
      render :edit
    end
  end

  def destroy
    if @route.discard
      flash[:success] = I18n.t "flash.driving_route.destroyed"
      redirect_to company_driving_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.driving_route.not_destroyed"
      render :edit
    end
  end

  private
    def set_route
      @route = policy_scope(DrivingRoute).find(params[:id])
      authorize @route
    end
end
