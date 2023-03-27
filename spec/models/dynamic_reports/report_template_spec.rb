# frozen_string_literal: true

require "rails_helper"

RSpec.describe DynamicReports::ReportTemplate, type: :model do

  describe :to_query do
    let(:id) { SecureRandom.uuid }

    before do
      ENV["DYNAMIC_REPORTING_URL"] = "https://localhost:3000"
      ActiveRecord::Base.connection.execute("insert into #{DynamicReports::ReportTemplate.table_name}(id, name, access_scope, report_definition, summary) values ('#{id}', 'Report 1', 0, '', '')")
    end

    describe "properties" do
      subject { DynamicReports::ReportTemplate.find(id)  }
      its(:url) { is_expected.to eq("https://localhost:3000/reports/" + subject.id) }
      its(:access_scope) { is_expected.to eq("standard_report") }
    end

    describe "for_company" do
      let(:company) { create(:company) }
      let(:company_report_id) { SecureRandom.uuid }
      before do


        ActiveRecord::Base.connection.execute("insert into #{DynamicReports::ReportTemplate.table_name}(id, name, access_scope, report_definition, summary) values ('#{company_report_id}', 'Report 2', 1, '', '')")
        ActiveRecord::Base.connection.execute("insert into #{DynamicReports::ReportTemplate.table_name}(id, name, access_scope, report_definition, summary) values ('#{SecureRandom.uuid}', 'Report 3', 2, '', '')")
        ActiveRecord::Base.connection.execute("insert into company_report_assignments(id, report_template_id, company_id) values ('#{SecureRandom.uuid}', '#{company_report_id}', #{company.id})")
      end

      it "fetches standard reports plus those assigned to companies" do
        reports = DynamicReports::ReportTemplate.by_company(company.id).pluck(:id)
        expect(reports).to include(company_report_id, id)
        expect(reports.length).to eq(2)
      end
    end


  end

end
