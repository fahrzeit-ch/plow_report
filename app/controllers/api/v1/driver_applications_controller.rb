# frozen_string_literal: true

class Api::V1::DriverApplicationsController < Api::V1::ApiController
  def index
    @records = DriverApplication.idle.where(user: current_resource_owner)
  end

  def create
    @record = DriverApplication.create(recipient: params[:recipient], user: current_resource_owner)
    if @record.valid?
      render :create, status: :created
    else
      head :bad_request
    end
  end
end
