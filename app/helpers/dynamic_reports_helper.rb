module DynamicReportsHelper
  def report_link(report_template)
    url = URI.join(ENV["DYNAMIC_REPORTING_URL"], "reports/", report_template.id)
    link_to t('views.companies.dynamic_reports.create_report'), url.to_s, target: "_blank"
  end
end