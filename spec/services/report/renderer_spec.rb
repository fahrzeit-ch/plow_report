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
      report.excel_report.attach io: subject.render, filename: "report.xlsx"
      expect(report.excel_report).to be_attached
    end

    context "with customers with the same name" do
      let(:customer1) { create(:customer, name: "Muster", company_id: company.id ) }
      let(:customer2) { create(:customer, name: "Muster", company_id: company.id ) }
      let(:site1) { create(:site, customer: customer1) }
      let(:site2) { create(:site, customer: customer2)}

      let(:drives) {[
        create(:drive, driver: create(:driver, company_id: company.id), customer: customer1),
        create(:drive, driver: create(:driver, company_id: company.id), customer: customer2)
      ]}

      subject { described_class.new(company, drives) }

      it "is attachable as a file to active_storage" do
        report.excel_report.attach io: subject.render, filename: "report.xlsx"
        expect(report.excel_report).to be_attached
      end
    end
  end

end
