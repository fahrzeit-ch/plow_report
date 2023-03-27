# frozen_string_literal: true

class DynamicReports::ReportTemplate < ApplicationRecord
  has_many :report_parameters
  has_many :company_report_assignments, class_name: "DynamicReports::CompanyReportAssignment"

  scope :by_company, -> (company_id) {
    left_joins(:company_report_assignments)
      .where(company_report_assignments: { company_id: company_id})
      .or(where(access_scope: :standard_report)) }

  enum access_scope: {
    standard_report: 0,
    company_report: 1,
    internal: 2
  }

  def url
    URI.join(ENV["DYNAMIC_REPORTING_URL"], "reports/", id).to_s
  end

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end