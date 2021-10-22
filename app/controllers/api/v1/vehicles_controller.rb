# frozen_string_literal: true

class Api::V1::VehiclesController < Api::V1::ApiController

  # Returns all vehicles assigned to the given company
  # Required params: company_id
  def index
    since = params[:changed_since] || 10.years.ago
    @records = Vehicle.with_discarded
                   .joins(:vehicle_activity_assignments)
                   .changed_since(since)
                   .where(company: current_company)
                   .order(sort_params(:name, :desc))
                   .distinct
                   .page(params[:page])
                   .per(params[:per_page])
  end
end
