# frozen_string_literal: true

module CompaniesHelper
  def company_view?
    true
  end

  def company_controller?
    /^company\// =~ params[:controller] || params[:controller] == "companies"
  end
end
