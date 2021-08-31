module Company::RoutesHelper

  def available_sites(route)
    company = route&.company || current_company
    Site.joins(:customer).where(customer: { client_of: company}).active.order(:display_name)
  end

  def available_driving_routes
    DrivingRoute.kept.order(:name).where(company_id: current_company.id)
  end

end
