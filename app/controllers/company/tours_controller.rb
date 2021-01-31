# frozen_string_literal: true

class Company::ToursController < ApplicationController
  before_action :set_company_from_param
  before_action :set_tour, only: [:destroy, :edit, :update]

  def index
    authorize current_company, :index_tours?
    scope = apply_scopes(current_company.tours
                             .kept
                             .includes(:driver))
    @records = scope.order(start_time: :desc)

    respond_to do |format|
      format.html do
        @stats = apply_scopes(current_company.drives).stats
        @records = @records.page(params[:page]).per(30)
      end
      format.js do
        @records = @records.page(params[:page]).per(30)
      end
      format.xlsx do
        @records
      end
    end
  end

  def destroy
    if @record.discard
      flash[:success] = I18n.t "flash.tours.destroyed"
    else
      flash[:error] = I18n.t "flash.tours.not_destroyed"
    end
    redirect_to company_tours_path current_company
  end

  def edit
    @record.full_validation = true
    @record.validate
  end

  def update
    if @record.update(tours_params)
      flash[:success] = I18n.t "flash.tours.updated"
      redirect_to edit_company_tour_path(current_company, @record)
    else
      render :edit
    end
  end

  private
    def apply_scopes(tours)
      tours = tours.by_season(selected_season)
      tours = tours.where(driver_id: params[:driver_id]) unless params[:driver_id].blank?
      tours
    end

    def tours_params
      permitted = policy(Tour).permitted_attributes
      permitted << :driver_id
      params.require(:tour).permit(permitted)
    end

    def set_tour
      @record = current_company.tours.find(params[:id])
      authorize @record
    end
end
