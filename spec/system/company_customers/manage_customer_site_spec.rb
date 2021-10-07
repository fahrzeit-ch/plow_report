# frozen_string_literal: true

require "rails_helper"

feature "Manage customer sites" do
  let(:company) { create(:company) }
  let(:site) { create(:site, customer: create(:customer, client_of: company)) }

  context "as non company admin" do
    let(:company_admin) { create(:user) }

    before do
      company.add_member(company_admin, CompanyMember::DRIVER)
      sign_in_with(company_admin.email, company_admin.password)
      visit(edit_company_customer_site_url(id: site.id, customer_id: site.customer.id, company_id: company.id))
    end

    it "redirects to company root" do
      expect(page).to have_current_path(company_dashboard_path(company))
    end
  end

  context "as company admin of other company" do
    let(:company_admin) { create(:user) }
    let(:other_company) { create(:company) }

    before do
      other_company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(edit_company_customer_site_url(id: site.id, customer_id: site.customer.id, company_id: company.id))
    end

    xit "is not possible to access customer sites", skip: "Currently it raises customer not found which is fine for now" do
      expect(page).to have_current_path(company_dashboard_path(other_company))
    end
  end

  context "as company admin", type: :system do
    let(:company_admin) { create(:user) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(edit_company_customer_site_path(id: site.id, customer_id: site.customer.id, company_id: company.id))
    end

    describe "required attributes" do

      let!(:activity_with_value) { create(:value_activity, company: company) }
      let!(:activity_without_value) { create(:activity, company: company) }

      before do
        click_link I18n.t('views.companies.sites.tab_label_additional_info')
      end

      it "lists all available activities that have additional value" do
        expect(page).to have_content(activity_with_value.name)
      end

    end

  end

end
