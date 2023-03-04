class DynamicReports::ReportTemplate < ApplicationRecord
  has_many :report_parameters

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end