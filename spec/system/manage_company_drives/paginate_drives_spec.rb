# frozen_string_literal: true

require "rails_helper"

feature "Edit Drive", type: :system do
  context "as compnay admin" do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }
    let!(:existing_drives) { create_list(:drive, 40, driver: driver) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_drives_path(company))
    end

    it "should load infinitly scroll", js: true  do
      page.find("#content").scroll_to(:bottom)
      sleep(0.5.second)
      expect(page.all('#drives > div.item-group').count).to eq 40
    end
  end
end
