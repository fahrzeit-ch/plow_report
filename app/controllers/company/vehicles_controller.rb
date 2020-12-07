# frozen_string_literal: true

class Company::VehiclesController < ApplicationController
  before_action :load_resource, only: [:update, :destroy, :edit]

  def index
    authorize current_company, :index_vehicles?
    @records = policy_scope(Vehicle)
                   .kept
                   .order(:name)
                   .page(params[:page])
                   .per(30)
  end

  def create
    @record = Vehicle.new permitted_attributes(Vehicle)
    @record.company = current_company

    authorize @record

    if @record.save
      flash[:success] = I18n.t("flash.vehicles.created")
      redirect_to company_vehicles_path current_company
    else
      flash[:error] = I18n.t("flash.vehicles.record_not_saved")
      render :new
    end
  end

  def edit
  end

  def update
    if @record.update permitted_attributes(@record)
      flash[:success] = I18n.t("flash.vehicles.updated")
      redirect_to company_vehicles_path current_company
    else
      flash[:error] = I18n.t("flash.vehicles.record_not_saved")
      render :edit
    end
  end

  def new
    @record = Vehicle.new
    authorize @record
  end

  def destroy
    if @record.discard
      flash[:success] = I18n.t("flash.common.deleted")
      redirect_to company_vehicles_path current_company
    else
      flash[:error] = I18n.t("flash.vehicles.not_destroyed")
      redirect_to_referral company_vehicles_path(current_company)
    end
  end

  private
    def load_resource
      @record = policy_scope(Vehicle).find(params[:id])
      authorize @record
    end
end
