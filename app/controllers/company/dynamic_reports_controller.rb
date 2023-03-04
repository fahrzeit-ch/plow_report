class Company::DynamicReportsController < ApplicationController
  before_action :set_company_from_param

  def index
    authorize current_company, :index_reports?
    @records = DynamicReports::ReportTemplate.where(access_scope: 0).includes(:report_parameters).order(:name)
  end

  private
    def redirect
      redirect_to company_tours_reports_path(current_company)
    end
end
