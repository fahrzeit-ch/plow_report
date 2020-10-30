# frozen_string_literal: true

class DriverApplicationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_account!
  layout "setup"

  def create
    @record = DriverApplication.create(permitted_attributes(DriverApplication).merge(user: current_user))
    if @record.valid?
      flash[:success] = t "flash.driver_applications.requested"
      redirect_to driver_application_path @record
    else
      flash[:error] = t "flash.driver_applications.request_failed"
    end
  end

  def show
    @record = DriverApplication.find_by(token: params[:id])
    authorize @record
  end

  def review
    @record = DriverApplication.find_by(token: params[:id])
    authorize @record
    if current_user.administrated_or_owned_companies.empty?
      render :not_an_owner
    else
      render :review
    end
  end

  def accept
    @record = DriverApplication.find_by(token: params[:id])
    @record.assign_attributes permitted_attributes(@record)
    authorize @record
    if @record.accept accepted_by: current_user
      flash[:success] = t "flash.driver_applications.accepted", username: @record.user.name
      redirect_to company_drivers_path(@record.accepted_to)
    else
      flash[:error] = t "flash.driver_applications.acception_failed"
      redirect_to review_driver_application_path @record
    end
  end

  private
    def resolve_layout
      "setup"
    end
end
