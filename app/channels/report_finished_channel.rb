# frozen_string_literal: true

class ReportFinishedChannel < ApplicationCable::Channel
  def subscribed
    report = ToursReport.find(params[:id])
    stream_for report
  end
end
