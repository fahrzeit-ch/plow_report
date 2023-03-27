# frozen_string_literal: true

class DynamicReports::ReportRequest
  include ActiveModel::Model

  attr_accessor :report_template
  attr_accessor :parameters
end