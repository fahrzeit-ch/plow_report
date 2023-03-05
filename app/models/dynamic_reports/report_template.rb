class DynamicReports::ReportTemplate < ApplicationRecord
  has_many :report_parameters

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