# frozen_string_literal: true

class Api::V1::DrivingRoutesController < Api::V1::ApiController
  def index
    since = params[:changed_since] || 10.years.ago
    @records = DrivingRoute.where(company_id: current_company.id)
                    .with_discarded
                    .changed_since(since)
                    .includes(:site_entries)
                    .page(params[:page])
                    .per(params[:per_page])
    render :index
  end
end
