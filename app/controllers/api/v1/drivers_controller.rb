# frozen_string_literal: true

class Api::V1::DriversController < Api::V1::ApiController
  def index
    service = DriversService.new
    @records = service.drivers_for(current_resource_owner, current_company).kept.includes(:company)
  end
end
