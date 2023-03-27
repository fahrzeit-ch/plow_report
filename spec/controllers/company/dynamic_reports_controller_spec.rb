# frozen_string_literal: true

require "rails_helper"
RSpec.describe Company::DynamicReportsController, type: :controller do
  let(:company) { create(:company) }
  let(:company_admin) { create(:user) }

  before { company.add_member company_admin, CompanyMember::OWNER }

  before { sign_in(company_admin) }

  describe "GET #index" do
    let(:driver) { create(:driver, company: company) }
    let(:other_member) { create(:company_member, company: company, role: :owner) }

    before { patch :index, params: { company_id: company.to_param } }

    it { expect(response).to be_successful }
  end
end
