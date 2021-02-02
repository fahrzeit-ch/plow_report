# frozen_string_literal: true

class TourReportJob < ApplicationJob
  include Rails.application.routes.url_helpers
  discard_on ActiveRecord::RecordNotFound

  def perform(report_id)
    report = ToursReport.find(report_id)

    renderer = Report::Renderer.new(report.company, report.drives)
    begin
      report.excel_report.attach io: renderer.render, filename: report.to_filename
      notify_admins_and_owners(report)
      update_report_items(report)
    rescue StandardError => e
      Rails.logger.error("Could not generate report: #{e.message}")
      Rollbar.notifier.error(e)
    end
  end

  def update_report_items(report)
    ReportFinishedChannel.broadcast_to(report, { path: company_tours_report_path(report.company, report) })
  end

  # @param [ToursReport] report
  def notify_admins_and_owners(report)
    report.company.company_members.admins_and_owners.each do |member|
      NotificationChannel.broadcast_to(
        member.user,
        title: I18n.t("flash.reports.read_title"),
        body: I18n.t("flash.reports.ready_body_html", url: company_tours_reports_path(report.company)),
        link_to: company_tours_reports_path(report.company, report)
      )
    end
  end

end
