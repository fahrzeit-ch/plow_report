class Company::DynamicReportsController < ApplicationController
  before_action :set_company_from_param

  def index
    authorize current_company, :index_reports?
    @records = DynamicReports::ReportTemplate.where(access_scope: 0).includes(:report_parameters).order(:name)
  end

  def edit
    template = DynamicReports::ReportTemplate.where(access_scope: 0).find(params[:id])
    @report = DynamicReports::ReportRequest.new report_template: template, parameters: template.report_parameters
  end

end
