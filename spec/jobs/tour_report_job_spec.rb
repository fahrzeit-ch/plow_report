# frozen_string_literal: true

require "rails_helper"

RSpec.describe TourReportJob, type: :job do
  let(:company) { create(:company) }

  context "without drives" do
    let(:report) { create(:tours_report, company: company) }
    subject { described_class.perform_now(report.id) }

    it "attaches xlsx file" do
      subject
      expect(report.excel_report).to be_attached
    end
  end
end
