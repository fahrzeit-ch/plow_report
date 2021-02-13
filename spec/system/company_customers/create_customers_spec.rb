# frozen_string_literal: true

require "rails_helper"

feature "Create Customer" do
  context "as non company admin" do
    let(:company_admin) { create(:user) }
    let(:company) { create(:company) }

    before do
      company.add_member(company_admin, CompanyMember::DRIVER)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_customers_path(company))
    end

    it "shows no customers info" do
      expect(page).to have_content(I18n.t('views.companies.customers.empty_info'))
    end

    it "is not possible to create new customer" do
      expect(page).not_to have_content(I18n.t('views.companies.customers.new'))
    end

    it "redirects to company root path if accessing new customer path" do
      visit(new_company_customer_path(company))
      expect(page).to have_current_path(company_dashboard_path(company))
    end
  end

  context "as company admin of other company" do
    let(:company_admin) { create(:user) }
    let(:other_company) { create(:company) }
    let(:company) { create(:company) }

    before do
      other_company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_customers_path(company))
    end

    it "is not possible to access index page" do
      expect(page).to have_current_path(company_dashboard_path(other_company))
    end

    it "redirects to company root path if accessing new customer path" do
      visit(new_company_customer_path(company))
      expect(page).to have_current_path(company_dashboard_path(other_company))
    end
  end

  context "as company admin" do
    let(:company_admin) { create(:user) }
    let(:company) { create(:company) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_customers_path(company))
    end

    it "shows no customers info" do
      expect(page).to have_content(I18n.t('views.companies.customers.empty_info'))
    end

    it "is possible to click on new and create a new customer" do
      click_on(I18n.t('views.companies.customers.new'))
      expect(page).to have_content(I18n.t("common.new"))
      fill_in("customer[name]", with: "Muster")
      fill_in("customer[first_name]", with: "Hans")
      fill_in("customer[street]", with: "Etzelstrasse")
      fill_in("customer[nr]", with: "52 A")
      fill_in("customer[zip]", with: "CH-8820")
      fill_in("customer[city]", with: "Brennau")

      click_on("Kunde erstellen")
      expect(page).to have_current_path("/companies/#{company.to_param}/customers/#{Customer.first.id}/edit")
      expect(page).to have_content("Muster")
    end

  end

end
