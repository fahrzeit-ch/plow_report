# frozen_string_literal: true

class TourReportJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(report_id)
    report = ToursReport.find(report_id)

    renderer = Report::Renderer.new(report.company, report.drives)
    begin
      report.excel_report.attach io: renderer.render, filename: report.to_filename
      report.save!
    rescue StandardError => e
      Logger.error("Could not generate report: #{e.message}")
    end
  end

end
