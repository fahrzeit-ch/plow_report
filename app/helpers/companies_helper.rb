module CompaniesHelper

  def company_view?
    company_controller?
  end

  def company_controller?
    /^company\// =~ params[:controller] || params[:controller] == 'companies'
  end

end
