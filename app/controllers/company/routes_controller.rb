class Company::RoutesController < ApplicationController
  before_action :set_route, only: %i[edit update destroy]

  def index
    @routes = policy_scope(Route).order(:name).page(params[:page]).per(50)
  end

  def new
    @route = Route.new(company: current_company)
    authorize @route
  end

  def edit
  end

  def create
    @route = Route.new(permitted_attributes(Route))
    @route.company = current_company
    authorize @route

    if @route.save
      flash[:success] = I18n.t "flash.route.created"
      redirect_to company_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.route.not_created"
      render :new
    end
  end

  def update
    if @route.update(permitted_attributes(Route))
      flash[:success] = I18n.t "flash.route.updated"
      redirect_to company_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.route.not_updated"
      render :edit
    end
  end

  def destroy
    if @route.destroy
      flash[:success] = I18n.t "flash.route.destroyed"
      redirect_to company_routes_path(current_company)
    else
      flash[:error] = I18n.t "flash.route.not_destroyed"
      render :edit
    end
  end

  private
    def set_route
      @route = policy_scope(Route).find(params[:id])
      authorize @route
    end
end
