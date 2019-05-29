class Company::ActivitiesController < ApplicationController

  before_action :set_company_from_param

  def index
    authorize current_company, :index_activities?
    @activities = current_company.activities.order(:name).all
  end

  def new
    @activity = Activity.new(has_value: false)
  end

  def edit
    @activity = current_company.activities.find(params[:id])
    authorize(@activity)
  end

  def create
    @activity = current_company.activities.build(activity_params)
    authorize @activity
    if @activity.save
      flash[:success] = I18n.t 'flash.activities.created'
      redirect_to company_activities_path(current_company)
    else
      render 'new'
    end
  end

  def update
    @activity = current_company.activities.find(params[:id])
    authorize(@activity)
    if @activity.update(activity_params)
      flash[:success] = I18n.t 'flash.activities.updated'
      redirect_to company_activities_path(current_company)
    else
      render 'edit'
    end
  end

  def destroy
    @activity = current_company.activities.find(params[:id])
    authorize(@activity)
    begin
      @activity.destroy
      flash[:success] = I18n.t 'flash.activities.destroyed'
    rescue ActiveRecord::DeleteRestrictionError => e
      flash[:error] = I18n.t 'flash.activities.not_destroyed'
    end
    redirect_to company_activities_path(current_company)
  end

  private

  def activity_params
    params.require(:activity).permit(:name, :has_value, :value_label)
  end
end
