# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report::Renderer do
  prepend RemoveUploadedFiles

  let(:company) { create(:company) }
  let(:drives) { create_list(:drive, 3, driver: create(:driver, company_id: company.id)) }

  subject { described_class.new(company, drives) }

  describe "render_stream" do
    let(:report) { build(:tours_report) }

    it "is attachable as a file to active_storage" do
      report.excel_report.attach io: subject.render_stream(subject.build_package), filename: "report.xlsx"
      expect(report.excel_report).to be_attached
    end

  end

end
