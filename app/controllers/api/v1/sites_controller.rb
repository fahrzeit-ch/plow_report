class Api::V1::SitesController < Api::V1::ApiController

  def index
    scope = Site.joins(:customer).where(customers: { company_id: company_id } )
    @records = scope.page(params[:page]).per(params[:perPage])

    render :index
  end
end
