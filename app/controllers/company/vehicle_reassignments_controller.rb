# frozen_string_literal: true

class Company::VehicleReassignmentsController < ApplicationController

  def create
    @reassignment = VehicleReassignment.new permitted_attributes(VehicleReassignment)
    authorize @reassignment
    if @reassignment.save
      flash[:success] = t('flash.vehicle_reassignments.reassigned')
      redirect_to edit_company_tour_path(current_company, @reassignment.tour)
    else
      flash[:error] = t('flash.vehicle_reassignments.reassignment_failed')
      render :new
    end
  end

  def prepare
    @reassignment = VehicleReassignment.new tour_id: params[:tour_id]
    authorize @reassignment
  end

end
