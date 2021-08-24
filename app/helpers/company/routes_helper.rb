module Company::RoutesHelper

  def available_sites(route)
    company = route.company
    Site.joins(:customer).where(customer: { client_of: company}).active.order(:display_name)
  end

end
