# frozen_string_literal: true

require "rails_helper"

RSpec.describe TourReportJob, type: :job do
  let(:company) { create(:company) }

  context "with drives" do
    let(:driver) { create(:driver, company: company) }
    let!(:drives) { create_list(:drive, 3, start: 1.day.ago, end: 1.day.ago + 1.hour, driver: driver) }
    let(:report) { create(:tours_report, company: company, start_date: 2.days.ago, end_date: DateTime.current) }
    subject { described_class.perform_now(report.id) }

    it "attaches xlsx file" do
      subject
      expect(report.excel_report).to be_attached
    end
  end
end
