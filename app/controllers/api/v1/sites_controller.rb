# frozen_string_literal: true

class Api::V1::SitesController < Api::V1::ApiController
  def index
    scope = Site.joins(:customer).where(customers: { company_id: company_id })
    @records = scope.order(sort_params(:display_name, :asc))
                    .includes(:requires_value_for)
                   .page(params[:page])
                   .per(params[:per_page])

    render :index
  end
end
