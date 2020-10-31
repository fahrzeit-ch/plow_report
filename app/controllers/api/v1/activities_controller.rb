# frozen_string_literal: true

class Api::V1::ActivitiesController < Api::V1::ApiController
  rescue_from ActionController::ParameterMissing, with: :handle_param_missing

  def index
    @records = Activity.where(company: company_id)
                   .order(sort_params(:name, :desc))
                   .page(params[:page])
                   .per(params[:per_page])
  end
end
