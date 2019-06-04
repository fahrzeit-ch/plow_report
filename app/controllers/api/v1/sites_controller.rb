class Api::V1::SitesController < Api::V1::ApiController

  def index
    scope = Site.joins(:customer).where(customers: { company_id: company.id } )
    @records = scope.page(params[:page]).per(params[:perPage])

    respond_to do |format|
      format.json { render :index }
    end
  end

  def company
    @company ||= current_resource_owner.companies.find_by!(slug: params[:company_id])
  end
end
